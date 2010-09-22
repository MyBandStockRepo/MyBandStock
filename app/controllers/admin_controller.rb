require 'MBS_API'

class AdminController < ApplicationController
  protect_from_forgery :only => [:send_users_email]
  before_filter :authenticated?, :user_has_site_admin
  skip_filter :update_last_location, :only => [:authorize_users_post, :index, :email_users_form]
  
  
  def index
  end


  def grant_shares
    @response_text = params[:response_text]
    @series_list = LiveStreamSeries.all
    @bands = Band.all
    @all_users_count = User.where(:receive_email_announcements => true).count
  end

  def grant_shares_post
  # Arbitrarily grant shares to users. Takes (user_id || user_email) && adjustment && band_id.
    # Check for band parameter
    if params[:band_id].blank? || params[:band_id] == 0 || (band = Band.find(params[:band_id])).nil?
      @response_text = 'Band ID not specified, or band does not exist.'
      redirect_to grant_shares_path(:response_text => @response_text) and return
    end
    
    # Check for adjustment parameter; it must be numerical.
    adjustment = params[:adjustment]
    if params[:adjustment].blank?
      @response_text = 'Please specify an adjustment'
      redirect_to grant_shares_path(:response_text => @response_text) and return
    else
      adjustment = adjustment if ( Integer(adjustment) rescue Float(adjustment) rescue false ) # Numeric
      unless adjustment
        @response_text = 'Adjustment must be numerical'
        redirect_to grant_shares_path(:response_text => @response_text) and return
      else
        adjustment = adjustment.to_i
        logger.info adjustment
      end
    end
  
    # Check for user parameter; we can take either user ID or user email.
    if params[:user_id].blank?
      if params[:user_email].blank?
        users = get_recipients()
        
        logger.info "Recipients [#{users && users.count }]"
        if users.blank?
          @response_text = 'Please provide user ID or email address.'
          redirect_to grant_shares_path(:response_text => @response_text) and return
        end
      else
        users = [User.where(:email => params[:user_email]).first]
        if users.blank? || users == [nil]
          @response_text = 'No user exists by that email address'
          redirect_to grant_shares_path(:response_text => @response_text) and return
        end
      end
    else
      users = [User.where(:id => params[:user_id]).first]
      if users.blank? || users == [nil]
        @response_text = 'No user exists by that ID'
        redirect_to grant_shares_path(:response_text => @response_text) and return
      end
    end
    
    # A response has been generated already, and we haven't awarded shares yet so it's probably not good, so we redirect.
    if !@response_text.blank?
      redirect_to grant_shares_path(:response_text => @response_text) and return
    end
    
    # Award shares
    @response_text = ''
    users.each{ |user|
      if ShareLedgerEntry.create(:user_id => user.id, :band_id => band.id, :adjustment => adjustment, :description => 'manual admin')
        @response_text += "Sucessfully granted #{ user.email } #{ adjustment } share(s) in #{ band.name }"
      else
        @response_text += "Error: unable to create share ledger entry. u=#{user.id}, a=#{adjustment}, b=#{band.id}"
      end
    }

    # Go back to form
    redirect_to grant_shares_path(:response_text => @response_text)
    return
  end


  def authorize_users
    @response_text = params[:response_text]
  end
  
  def authorize_users_post
    unless params[:email] && params[:lss_id] && !params[:email].blank?
      @response_text = 'Invalid input - please specify an email address and a Live Stream Series'
      return redirect_to :action => :authorize_users, :response_text => @response_text
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
    
    unless params[:admin].blank? || params[:admin][:to].blank? || params[:admin][:subject].blank? || params[:admin][:message].blank?
      @subject = params[:admin][:subject]
      @message =  params[:admin][:message]
      
      @to_users = get_recipients()
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
            
      unless @to_users.blank?
  			UserMailer.send_announcement(@to_users, @subject, @message).deliver
        flash[:notice] = "Emails sent."
        redirect_to :action => 'index'
      else
        flash[:error] = "No users fit this group to send an email to."
        redirect_to :action => 'index'        
      end
      
    end    
  end

private

  def get_recipients()
  # Based on params[:admin], returns an array of selected users, or false on error.
  #
    return false if params[:admin].blank?
    
    to = params[:admin][:to]
    logger.info "To: #{to}"
    #if to all, get all users, etc...      
    if to == 'bandtop10'
      band = Band.find(params[:admin][:bandtop10_id])
      unless band.nil?
        to_users = band.top_ten_shareholders().collect{|shareTotal| shareTotal.user}         
      else
        #couldn't find band
        flash[:error] = "Could not find band."
        error = true
      end
    elsif to == 'lss'
      lss = LiveStreamSeries.find(params[:admin][:live_stream_series_id])
      unless lss.nil?
        to_users = lss.users_with_permissions()
      else
        #couldn't find lss
        flash[:error] = "Could not find Series."
        error = true         
      end
    elsif to == 'band'
      band = Band.find(params[:admin][:bandall_id])
      unless band.nil?
        to_users = band.all_shareholder_users()
      else
        #couldn't find band
        flash[:error] = "Could not find band."
        error = true
      end
    elsif to == 'all'
      to_users = User.all
    else
      flash[:error] = 'Please select recipients'
      error = true
    end
    
    return false if error
    
    logger.info to_users.to_yaml
    return to_users
  end


end #controller

