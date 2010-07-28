require 'google4r/checkout'

class GoogleCheckoutOrder < ActiveRecord::Base

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
    shopping_cart = Google4R::Checkout::ShoppingCart.create_from_element(REXML::Document.new(self.shopping_cart_xml).root, 2) #the 2 is random, its the "owner" parameter but we dont care who the owner is ---
    
    #first iterate over the items to find the contribution level(s)  Contribution levels have item id's encoded as follows "cl-cl_id-user_id-project_id
    target_user_id = nil
    list_of_contribution_levels = Array.new
    project_id = nil
    for item in shopping_cart.items
      item_id_params_array = item.id.strip.split('-')
      if item_id_params_array[0] == 'stock'
        target_user_id = item_id_params_array[3].to_i
        list_of_contribution_levels.push item_id_params_array[1].to_i
        project_id = item_id_params_array[3].to_i
      end
    end
    list_of_contribution_levels.uniq! #remove dupes
    #make the entry(ies) in the Contribution table
    #for contribution_level_id in list_of_contribution_levels
    #  contribution = Contribution.new() do |c|
    #    c.user_id = target_user_id
    #    c.band_id = ContributionLevel.find_by_id(contribution_level_id).band.id
    #    c.contribution_level_id = contribution_level_id
    #    c.project_id = project_id
    #    c.google_checkout_order_id = self.id
    #    c.save
    #  end
    #end
  
    #RAILS_DEFAULT_LOGGER.warn('self data: c: ' + (self.city || '') + ' p: ' + (self.postal_code || '') + ' a1: ' + (self.address1 || '') + ' a2: ' + (self.address2 || '') + ' r: ' + (self.region || ''))
    #update the user info
    #now see if the user account should be updated
    u = User.find(target_user_id)
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
    
    
    
    #now check and see if the project is finished
    current_project = Project.find_by_id(project_id)
    if (Contribution.find_all_by_project_id(project_id, :include => :contribution_level).collect{|c| c.contribution_level.us_dollar_amount}.sum >= current_project.value)
      current_project.complete = true
      current_project.active = false
      current_project.save
    end
    
    #now grant the perks
    grant_order_perks()
    
    
  end
  
  
  
  private
  
  
  def grant_order_perks
    shopping_cart = Google4R::Checkout::ShoppingCart.create_from_element(REXML::Document.new(self.shopping_cart_xml).root, 2) #the 2 is random, its the "owner" parameter but we dont care
    #first iterate over the items to find the contribution level (one of them is all we need) to grab the user id so we know who the perks go to.  Contribution levels have item id's encoded as follows "cl-cl_id-user_id
    target_user_id = nil
    target_user = nil
    for item in shopping_cart.items
      if item.id.strip.split('-')[0] == 'cl'
        contribution_level_id = item.id.strip.split('-')[1].to_i
        puts('cl: ' +contribution_level_id.to_s)
        target_user_id = item.id.strip.split('-')[2].to_i
        target_user = User.find(target_user_id)
        contribution_level = ContributionLevel.find(contribution_level_id)
        for perk in contribution_level.perks
          #grant them the perk, the grant_perk function can be found on the user model
          target_user.grant_perk(:perk_id => perk.id, :contribution_level_id => contribution_level.id, :filled => false, :google_checkout_order_id => self.id)
        end
      end
    end
  
  end
  
 
  
#end model class 
end
