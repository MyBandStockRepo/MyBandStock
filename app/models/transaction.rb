require 'google4r/checkout'

class Transaction < ActiveRecord::Base

  belongs_to :user
  
  def update_user_id
    shopping_cart = Google4R::Checkout::ShoppingCart.create_from_element(REXML::Document.new(self.shopping_cart_xml).root, 2) #the 2 is random, its the "owner" parameter but we dont care who the owner is ---
    #first iterate over the items to find the contribution level(s)  Contribution levels have item id's encoded as follows "cl-cl_id-user_id-project_id
    target_user_id = nil
    for item in shopping_cart.items
      item_id_params_array = item.id.strip.split('-')
      if item_id_params_array[0] == 'cl'
        target_user_id = item_id_params_array[2].to_i
        break
      end
    end
    self.user_id = target_user_id
    self.save
  end
  
  
  def process_paid_order
  # Apply newly-purchased perks.
  # An example item ID:
  #  "stock-4-100-49" which is "stock-bandID-numShares-userID"
  #
    logger.info "Processing paid Google Checkout order."
    shopping_cart = Google4R::Checkout::ShoppingCart.create_from_element(REXML::Document.new(self.shopping_cart_xml).root, 2) #the 2 is random, its the "owner" parameter but we dont care who the owner is ---
    
    target_user_id = nil
    success = true

    # We iterate over the items in the shopping cart, assigning shares appropriately. 
    for item in shopping_cart.items
      item_id_params_array = item.id.strip.split('-')
      case item_id_params_array[0]
        when 'stock'
          target_user_id  = item_id_params_array[3].to_i
          band_id         = item_id_params_array[1].to_i
          num_shares      = item_id_params_array[2].to_i
          
          user = User.find(target_user_id)  # Though unlikely, we assume that each shopping cart item has a different user ID.
          if (user)
            update_user_information(user)
            logger.info "Direct stock purchase: granting user #{user.id}  #{num_shares} shares in band #{band_id}."
            success = success && ShareLedgerEntry.create(
                                                    :user_id      => target_user_id,
                                                    :band_id      => band_id,
                                                    :adjustment   => num_shares,
                                                    :description  => 'direct_purchase'
                                                  )
          else
            success = false
          end
        when 'lss'
        else
          success = false
      end
    end #for
    
    return success
  end #def
  
private
    
  def update_user_information(user_object)
    #update the user info
    #now see if the user account should be updated
    u = user_object
    if (u)
      #RAILS_DEFAULT_LOGGER.warn('user: ' + u.nickname)
      unless ( (u.city != '') && (!u.city.nil?) )
        u.city = self.city
        u.save
      end
      unless ( (u.zipcode != '') && (!u.zipcode.nil?) )
        u.zipcode = self.postal_code
        u.save
      end
      unless ( (u.address1 != '') && (!u.address1.nil?) )
        u.address1 = self.address1
        u.save
      end
      unless ( (u.address2 != '') && (!u.address2.nil?) )
        u.address2 = self.address2
        u.save
      end
    end #if      
  end #def
  
 
  
#end model class 
end
