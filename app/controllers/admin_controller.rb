require 'MBS_API'

class AdminController < ApplicationController

  before_filter :authenticated?
  before_filter :user_has_site_admin
  skip_filter :update_last_location, :only => [:authorize_users_post]
  
  
  def index
    #something
  end

  def authorize_users
    @response_text = params[:response_text]
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
    redirect_to :action => :authorize_users, :response_text => @response_text
  end
  
  
  def email_users_form
    #everyone
    #shres in a given band
    #permission on given series
    #top 10
    @series_list = LiveStreamSeries.all
    @bands = Band.all
    
    
  end
  
  def send_users_email
    #unless missing params
    unless params[:admin].nil? || params[:admin][:to].nil? || params[:admin][:subject].nil? || params[:admin][:subject] == '' || params[:admin][:message].nil? || params[:admin][:message] == ''
      @to = params[:admin][:to]
      @subject = params[:admin][:subject]
      @message =  params[:admin][:message]
      
      #HERE  if to all, get all users, etc...
      
      
#      @series = LiveStreamSeries.find(params[:admin][:live_stream_series_id])
#      @band = Band.find(params[:admin][:band_id])
    else
      #since there is no admin model, and we want to display errors and re-render the form, need dot operators to work for admin.  ex, we need admin.band_id to return the band id, so we must create a struct and that allows the dot operator to work
      emailFormStruct = Struct.new(:live_stream_series_id, :band_id, :subject, :message)       
      @series_list = LiveStreamSeries.all
      @bands = Band.all
      @admin = emailFormStruct.new(params[:admin][:live_stream_series_id].to_i, params[:admin][:band_id].to_i, params[:admin][:subject], params[:admin][:message])
      render :action => 'email_users_form'
    end
  end
#end controller
end
