class LegalController < ApplicationController
 skip_filter :update_last_location

  def tos
    redirect_to :action => :privacy_policy and return  # Right now we lack a TOS
  end
  
  
  def privacy_policy
  
  end
  
  
end
