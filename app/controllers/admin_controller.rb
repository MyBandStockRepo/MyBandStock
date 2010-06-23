require 'MBS_API'

class AdminController < ApplicationController

  before_filter :authenticated?
  before_filter :user_has_site_admin
  skip_filter :update_last_location, :only => [:authorize_users_post]
  
  
  def index
    #something
  end

  def authorize_users
    
  end
  
  def authorize_users_post
    unless params[:email] && params[:lss_id]
      @response_text = 'Invalid input - please specify an email address and a Live Stream Series'
      return false
    end
    unless MBS_API.change_stream_permission( { :api_key => OUR_MBS_API_KEY,
                                               :hash => OUR_MBS_API_HASH,
                                               :api_version => '.1',
                                               :email => params[:email],
                                               :stream_series => params[:lss_id],
                                               :can_view => 1,
                                               :can_chat => 1,
                                               :can_listen => 1 } )
      @response_text = 'Failed - change_stream_permissions returned false'
    else
      @response_text = "#{ params[:email] } authorized."
    end
  end
  
#end controller
end
