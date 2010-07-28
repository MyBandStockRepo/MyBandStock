require 'google4r/checkout'
include Google4R::Checkout

class MerchantController < ApplicationController

  def make_stock_purchase
    
    # Make sure user is logged in. If not, send him to the appropriate login view.
    unless session[:auth_success] == true
      if params[:lightbox].nil?
        update_last_location and redirect_to :controller => 'login', :action => 'user'
      else
        @external = true
        @login_only = true  # Tell the login view to only show the login form
        update_last_location and redirect_to :controller => 'login', :action => 'user', :lightbox => 'true', :login_only => 'true'
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
    if num_shares.nil? || num_shares == 0 || num_shares < 1 || num_shares > 1000
      flash[:error] = 'Could not buy stock: share amount must be between 1 and 1000.'
      redirect_to buy_stock_path(:lightbox => params[:lightbox]) and return
    end
    
    #begin the transaction
    @frontend = Google4R::Checkout::Frontend.new(GOOGLE_CHECKOUT_CONFIGURATION)
    @frontend.tax_table_factory = TaxTableFactory.new
    checkout_command = @frontend.create_checkout_command
    
    #get the project_id for the band
    project_id = contribution_level.band.active_project.id
    # Adding an item to shopping cart
    checkout_command.shopping_cart.create_item do |item|      
      item.name = "#{contribution_level.number_of_shares} shares in #{contribution_level.band.name}"
      item.description = "#{contribution_level.number_of_shares} shares in #{contribution_level.band.name}"
      item.unit_price = Money.new(contribution_level.us_dollar_amount*100, "USD") #this takes cents
      item.quantity = 1
      item.id = "cl-#{contribution_level.id}-#{session[:user_id]}-#{project_id}"
    end
    
    #add the perks
    for perk in contribution_level.perks
      checkout_command.shopping_cart.create_item do |item|      
        item.name = "#{perk.name}"
        item.description = "#{perk.description}"
        item.unit_price = Money.new(0, "USD")
        item.quantity = 1
        item.id = "p-#{perk.id}"
      end
    end
    
    # Create a flat rate shipping method for lower 48
    checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
      shipping_method.name = "Free to Continental-US"
      shipping_method.price = Money.new(0, "USD")
      # Restrict shipping to US-48
      shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
        area.area = Google4R::Checkout::UsCountryArea::CONTINENTAL_48
      end
    end
    
    # Create a flat rate shipping method for HI and AL
    checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
      shipping_method.name = "HI+AL Flat Rate"
      shipping_method.price = Money.new(8, "USD")
      # Restrict shipping to HI+AL
      shipping_method.create_allowed_area(Google4R::Checkout::UsStateArea) do |area|
        area.state = 'HI'
      end
      shipping_method.create_allowed_area(Google4R::Checkout::UsStateArea) do |area|
        area.state = 'AL'
      end
    end
    
    checkout_command.continue_shopping_url = "#{SITE_URL}/me/purchases"
    response = checkout_command.send_to_google_checkout    
    redirect_to response.redirect_url    

  end
end

