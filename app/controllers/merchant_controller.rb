require 'google4r/checkout'

class MerchantController < ApplicationController
  ssl_required :google_checkout_callback
  before_filter :google_checkout_callback_basic_auth, :only => 'google_checkout_callback'


  def make_stock_purchase
  # buy_stock POSTs to here
  #
    # Make sure user is logged in. If not, send him to the appropriate login view.
    unless session[:auth_success] == true
      if params[:lightbox].nil?
        redirect_to :controller => 'login', :action => 'user'
      else
        @external = true
        @login_only = true  # Tell the login view to only show the login form
        redirect_to :controller => 'login', :action => 'user', :lightbox => 'true', :login_only => 'true'
      end
      return false
    end

    # Check to assure the band exists.
    band = ( (params[:band_id]) ? Band.find(params[:band_id].to_i) : nil )
    if band.nil?
      flash[:error] = 'Could not buy stock: band does not exist or was not specified.'
      redirect_to buy_stock_path(:lightbox => params[:lightbox]) and return
    end

    #make sure num_shares is good
    num_shares = params[:num_shares].to_i
    if num_shares.nil? || num_shares == 0 || num_shares < MINIMUM_SHARE_PURCHASE || num_shares > 1000
      flash[:error] = 'Could not buy stock: share amount must be between ' + MINIMUM_SHARE_PURCHASE.to_s + ' and 1000.'
      redirect_to buy_stock_path(:lightbox => params[:lightbox]) and return
    end
    
    # Assure that there are shares available for purchase today.
    available_shares = band.available_shares_for_purchase
    if available_shares <= 0 || num_shares > available_shares
      if (available_shares <= 0)
        flash[:error] = "There are no more shares available today! Check back soon - new shares are released every day at noon."
      else
        flash[:error] = "There aren't that many shares available! You can buy up to #{ available_shares } until more are released."
      end
      redirect_to buy_stock_path(:lightbox => params[:lightbox]) and return
    end
    
    #begin the transaction
    @frontend = Google4R::Checkout::Frontend.new(GOOGLE_CHECKOUT_CONFIGURATION)
    @frontend.tax_table_factory = TaxTableFactory.new
    checkout_command = @frontend.create_checkout_command
    total_cost = num_shares * band.share_price()

    # Adding an item to shopping cart
    # The product ID for stock looks like "stock-bandID-numShares-userID", like
    #   "stock-4-100-49"
    checkout_command.shopping_cart.create_item do |item|      
      item.name = "#{num_shares} shares in #{band.name}"
      item.description = "Exclusive MyBandStock.com stock in #{band.name}"
      item.unit_price = Money.new(total_cost, "USD") #this takes cents
      item.quantity = 1
      item.id = "stock-#{band.id}-#{num_shares}-#{session[:user_id]}"
    end
    
    # Create a flat rate shipping method for the world
    checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
      shipping_method.name = "Free - electronic delivery"
      shipping_method.price = Money.new(0, "USD")
      # Restrict shipping to US-48
      shipping_method.create_allowed_area(Google4R::Checkout::WorldArea)
    end
    
    checkout_command.continue_shopping_url = url_for(band)
    response = checkout_command.send_to_google_checkout
    
    if params[:lightbox]
      redirect_to :controller => :application, :action => :break_out_of_lightbox, :target => response.redirect_url
      return
    else
      redirect_to response.redirect_url and return
    end

  end  
  
  
  def google_checkout_callback

    response = REXML::Document.new(request.raw_post)  #?!?! I think??? No documentation for this shit.  Yeah thats right I said it.
    logger.info "Google Checkout callback XML: " + response.to_s
    
    ### ASSERT
    unless response.has_elements?
      #ABORT, bad request
      render :nothing => true
      return false
    end
    
    #Grab Google Checkout 'order number' from XML
    google_order_number = response.root().elements.to_a("//google-order-number/")[0].text.to_s #GOOGLE HAS SPECIFIED THIS IS A STRING
    
    ### ASSERT
    unless google_order_number.length > 0
      #ABORT, bad request
      render :nothing => true
      return false
    end

    a_frontend = Google4R::Checkout::Frontend.new(GOOGLE_CHECKOUT_CONFIGURATION)
    a_frontend.tax_table_factory = TaxTableFactory.new

    #if str_googleordernum.strip
    #TROUBLESHOOT: send email of XML from Google
    #sendemail(request.raw_post, str_googleordernum.to_s)

    #see if ordernumber exists.. if so proceed.. if not, bail and give Google Notification
    if google_checkout_order = Transaction.find_by_google_order_number(google_order_number) 
      case response.root().name
        when "order-state-change-notification" then
          oscn = Google4R::Checkout::OrderStateChangeNotification.create_from_element(response.root, a_frontend)
          process_order_state_change_notification(oscn)
        when "risk-information-notification" then
          rin = Google4R::Checkout::RiskInformationNotification.create_from_element(response.root, a_frontend)
          process_risk_information_notification(rin)
        when "refund-amount-notification" then
          ran = Google4R::Checkout::RefundAmountNotification.create_from_element(response.root, a_frontend)
          process_refund_amount_notification(ran)
        when "charge-amount-notification" then
          can = Google4R::Checkout::ChargeAmountNotification.create_from_element(response.root, a_frontend)
          process_charge_amount_notification(can)
        
      else
                #TODO, maybe send an email about some unrecognized function
      end
    else
      case response.root().name
        when "new-order-notification" then
          new_order_notification = Google4R::Checkout::NewOrderNotification.create_from_element(response.root, a_frontend)
          cart_xml = response.root().elements.to_a("//shopping-cart/")[0].to_s
          create_new_google_checkout_order_from_notification(new_order_notification, cart_xml) #although it seems silly, without writing something custom it isn't easy to get the xml back out of the NewOrderNotification object without serializing it myself and I'm lazy.
      else
      end
    end
    
    #let google know everything was successful so they dont retry
    render :text => "<notification-acknowledgment xmlns=\"http://checkout.google.com/schema/2\" serial-number=\"#{response.root.attributes["serial-number"]}\"/>", :layout => false
    #below is the built in response which is out of date because it doesn't return the serial number of the notification and doesn't take params...
    #render :text => Google4R::Checkout::NotificationAcknowledgement.new.to_xml, :layout => false 
    return
  end


private


  def create_new_google_checkout_order_from_notification(new_order_notification, cart_xml)
    google_order = Transaction.new do |o|
      returning new_order_notification do |n|
        #global idents
        o.buyer_id = n.buyer_id
        o.serial_number = n.serial_number
        o.google_order_number = n.google_order_number
        #order meta-info
        o.financial_order_state = n.financial_order_state.to_s
        o.fulfillment_order_state = n.fulfillment_order_state.to_s
        o.email_allowed = n.marketing_preferences.email_allowed
        o.order_total = n.order_total.cents/100.to_f #turn pennies into a dollar float
        o.timestamp = n.timestamp
        #buyer address information
        o.address1 = n.buyer_shipping_address.address1
        o.address2 = n.buyer_shipping_address.address2
        o.city = n.buyer_shipping_address.city
        o.company_name = n.buyer_shipping_address.company_name
        o.contact_name = n.buyer_shipping_address.contact_name
        o.country_code = n.buyer_shipping_address.country_code
        o.email = n.buyer_shipping_address.email
        o.fax = n.buyer_shipping_address.fax
        o.phone = n.buyer_shipping_address.phone
        o.postal_code = n.buyer_shipping_address.postal_code
        o.region = n.buyer_shipping_address.region
        #and the shopping cart for good measure
        o.shopping_cart_xml = cart_xml
      end
    end
    google_order.paid = false
    google_order.total_amount_charged = 0
    google_order.save
    
    #update the user_id on the order
    google_order.update_user_id
    
    
  end
  
  def process_order_state_change_notification(order_state_change_notification)
    google_order = Transaction.find_by_google_order_number(order_state_change_notification.google_order_number)
    
    returning google_order do |g|
      returning order_state_change_notification do |o|
        g.financial_order_state = o.new_financial_order_state
        g.fulfillment_order_state = o.new_fulfillment_order_state
      end
      g.save
    end
    
    if (google_order.financial_order_state == 'CHARGEABLE')
      charge_command = order_state_change_notification.frontend.create_charge_order_command
      charge_command.google_order_number = google_order.google_order_number
      begin
        response = charge_command.send_to_google_checkout
      rescue Google4R::Checkout::GoogleCheckoutError
        logger.info "Google Checkout: 'You cannot charge an order that is already completely charged'"
      end
      logger.info response
    end
  end
  
  def process_risk_information_notification(risk_information_notification)
    #for now, do nothing
    
    #possible fields include
    # avs_response, buyer_account_age, buyer_billing_address, cvn_response, eligible_for_protection, google_order_number, ip_address, partial_card_number, serial_number, timestamp
  end
  
  def process_refund_amount_notification(refund_amount_notification)
    #for now, do nothing
    
    #possible fields include
    # google_order_number, latest_refund_amount, serial_number, timestamp, total_refund_amount
  end
  
  def process_charge_amount_notification(charge_amount_notification)
    logger.info "Processing Google Checkout charge notification."
    returning charge_amount_notification do |c|
      google_order = Transaction.find_by_google_order_number(c.google_order_number)
      google_order.total_amount_charged = c.total_charge_amount.cents/100.to_f
      google_order.save
      if (google_order.total_amount_charged >= google_order.order_total)
        #mark the order as paid and grant their perks
        google_order.paid = true
        google_order.save
        order_success = google_order.process_paid_order()
      end  
    end
  end

  
  
  def google_checkout_callback_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
        username == GOOGLE_CHECKOUT_CONFIGURATION[:merchant_id] && password == GOOGLE_CHECKOUT_CONFIGURATION[:merchant_key]
      end
  end


end

