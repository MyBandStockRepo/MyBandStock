class AdminController < ApplicationController

  before_filter :authenticated?
  before_filter :user_has_site_admin
  
  
  def index
    #something
  end
  
#end controller
end
