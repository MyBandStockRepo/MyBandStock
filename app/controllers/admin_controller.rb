require 'MBS_API'

class AdminController < ApplicationController
  protect_from_forgery :only => [:send_users_email]
  before_filter :authenticated?
  before_filter :user_has_site_admin
  skip_filter :update_last_location, :only => [:authorize_users_post, :index, :email_users_form]
  
  
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
    all_users = User.all.select{|u| u.receive_email_announcements == true}
    if all_users.nil?
      @all_users_count = 0
    else
      @all_users_count = all_users.count
    end
    
    
  end
  
  def send_users_email
    #unless missing params
    error = false    
    
    all_users = User.all.select{|u| u.receive_email_announcements == true}
    if all_users.nil?
      @all_users_count = 0
    else
      @all_users_count = all_users.count
    end    
    
    unless params[:admin].nil? || params[:admin][:to].nil? || params[:admin][:subject].nil? || params[:admin][:subject] == '' || params[:admin][:message].nil? || params[:admin][:message] == ''
      @to = params[:admin][:to]
      @subject = params[:admin][:subject]
      @message =  params[:admin][:message]
      
      #if to all, get all users, etc...      
      if @to == 'bandtop10'
        @band = Band.find(params[:admin][:bandtop10_id])
        unless @band.nil?
          @to_users = @band.top_ten_shareholders().collect{|shareTotal| shareTotal.user}         
        else
          #couldn't find band
          flash[:error] = "Could not find band."
          error = true
        end
      elsif @to == 'lss'
        @lss = LiveStreamSeries.find(params[:admin][:live_stream_series_id])
        unless @lss.nil?
          @to_users = @lss.users_with_permissions()
        else
          #couldn't find lss
          flash[:error] = "Could not find Series."
          error = true         
        end
      elsif @to == 'band'
        @band = Band.find(params[:admin][:bandall_id])
        unless @band.nil?
          @to_users = @band.all_shareholder_users()
        else
          #couldn't find band
          flash[:error] = "Could not find band."
          error = true
        end
      else
        @to_users = User.all
      end      
    else
      #since there is no admin model, and we want to display errors and re-render the form, need dot operators to work for admin.  ex, we need admin.band_id to return the band id, so we must create a struct and that allows the dot operator to work
      flash[:error] = "Could not find parameters."
      error = true
    end
    
    if error == true
      emailFormStruct = Struct.new(:live_stream_series_id, :bandall_id, :bandtop10_id, :subject, :message)       
      @series_list = LiveStreamSeries.all
      @bands = Band.all
      @admin = emailFormStruct.new(params[:admin][:live_stream_series_id].to_i, params[:admin][:bandall_id].to_i, params[:admin][:bandtop10_id].to_i,params[:admin][:subject], params[:admin][:message])
      render :action => 'email_users_form'      
    else
      
      #filter out users who don't want email
      @to_users = @to_users.select{|u| u.receive_email_announcements == true}
      #pull out the email address
     # @to_emails = @to_users.collect{|u| u.email}
            
      unless @to_users.nil? || @to_users.size == 0
  			UserMailer.send_announcement(@to_users, @subject, @message).deliver
        flash[:notice] = "Emails sent."
        redirect_to :action => 'index'
      else
        flash[:error] = "No users fit this group to send an email to."
        redirect_to :action => 'index'        
      end
      
    end    
  end
#end controller
end
