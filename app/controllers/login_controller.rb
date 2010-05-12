class LoginController < ApplicationController

  skip_filter :update_last_location
  protect_from_forgery :only => [:process_user_login]
  
  ssl_required :user, :process_user_login, :admin
  
  
  def user
    if ( (user_id = cookies[:saved_user_id]) && (salted_string = cookies[:salted_user_id]) )
      if (Digest::SHA256.digest(user_id.to_s+SHA_SALT_STRING) == salted_string)
        session[:auth_success] = true
        session[:user_id] = user_id.to_i
        flash[:notice] = "Thanks for logging in " + User.find(session[:user_id]).full_name + "!"
        redirect_to session[:last_clean_url]
      end
    end
  end
  
      
  def process_user_login
    if params[:user].nil? || params[:user][:email].nil? || params[:user][:password].nil?
      if params[:email].nil? || params[:password].nil?
        flash[:notice] = "Email and password not sent appropriately."
        render :controller => 'login', :action => :user
        return false
      else
        passed_email = params[:email]
        passed_password = params[:password]
      end
    else
      passed_email = params[:user][:email]
      passed_password = params[:user][:password]
    end
    if ( @user = Email.find_by_address(passed_email).user ) && ( @user.password == Digest::SHA256.new(passed_password) )
      session[:auth_success] = true
      session[:user_id] = @user.id
      flash[:notice] = "Thanks for logging in " + @user.full_name + "!"
      #if they wanted to be remembered, do it
      if (params[:remember] == '1')
        cookies[:saved_user_id] = {:value => @user.id.to_s, :expires => 14.days.from_now}
        cookies[:salted_user_id] = {:value => Digest::SHA256.digest(@user.id.to_s+SHA_SALT_STRING), :expires => 14.days.from_now}
      end
      if session[:last_clean_url]
        redirect_to session[:last_clean_url]
        return true
      else
        redirect_to :controller => 'login', :action => 'user'
        return false
      end
    else
      flash[:notice] = "Email and password do not match."
      @user = User.new(:email => passed_email)
      render :controller => 'login', :action => :user
      return false
    end
  end
      
      
  def admin
    if session[:has_admin] == true
      return true
    end
    unless session[:user].nil?
      #you should probably replace this with the ID of the admin role as the lookup would probaby be much quicker
      if User.find(session[:user_id]).has_role? :role_name => "admin"
        session[:has_admin] = true
        return false
      end
    end
      
  end
  
  
  def password_reminder
    @reminder_sent = false
    if ( params[:email] && (search_email = params[:email].strip) && (search_email != '') )
      if @user = User.find_by_email(search_email)
        UserNotifier.deliver_password_reminder(@user.id)
        @reminder_sent = true
      else
        @bad_email = true
      end
    end
    
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
  
  end
      
  def logout
    reset_session #this is a built in rails method
    redirect_to :controller => 'application', :action => 'index'
    cookies.delete(:saved_user_id)
    cookies.delete(:salted_user_id)
    return true
  end

end
