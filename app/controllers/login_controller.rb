class LoginController < ApplicationController

  skip_filter :update_last_location
  skip_filter :update_last_controller_and_action, :only => :user  # Otherwise last_controller and last_action would be invalidated when the user is redirected to https/
  protect_from_forgery :only => [:process_user_login, :forgot_password]
  
  ssl_required :user, :process_user_login, :admin
  
  
  def user
    logger.info "LCU: #{ session[:last_clean_url] }"
    if session[:user_id]
      redirect_to '/me/home'
      return false
    end
    if ( (user_id = cookies[:saved_user_id]) && (salted_string = cookies[:salted_user_id]) )
      if (Digest::SHA256.digest(user_id.to_s+SHA_SALT_STRING) == salted_string)
        session[:auth_success] = true
        session[:user_id] = user_id.to_i
        flash[:notice] = "Thanks for logging in " + User.find(session[:user_id]).full_name + "!"
        redirect_to session[:last_clean_url]
        return true
      end
    end
    
    set_view_variables()
	  unless params[:lightbox].nil?
      # If our request tells us not to display layout (in a lightbox, for instance)
      @external = true  # The view needs to know whether to include the "external" login partial or default one.
      render :layout => 'lightbox'
    end

  end
  
      
  def process_user_login
    logger.info 'Beginning proces_user_login'
    if params[:user].nil? || params[:user][:email].nil? || params[:user][:password].nil?
      logger.info 'Test:'
      logger.info params.inspect
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
    if ( @user = User.find_by_email(passed_email) ) && ( @user.password == Digest::SHA2.hexdigest(passed_password) )
			log_user_in(@user.id)
      flash[:notice] = "Thanks for logging in " + @user.full_name + "!"
      #if they wanted to be remembered, do it
      if (params[:remember] == '1')
        cookies[:saved_user_id] = {:value => @user.id.to_s, :expires => 14.days.from_now}
        cookies[:salted_user_id] = {:value => Digest::SHA256.digest(@user.id.to_s+SHA_SALT_STRING), :expires => 14.days.from_now}
      end
      if session[:last_clean_url]
        redirect_to session[:last_clean_url], :lightbox => params[:lightbox]
        return true
      else
        redirect_to :controller => 'login', :action => 'user', :lightbox => params[:lightbox]
        return false
      end
    else
      flash[:error] = "Email and password do not match."
      @user = User.new(:email => passed_email)
      unless params[:lightbox].nil?
        @external = true
        @login_only = params[:show_login_only]  # Tell the view to only show the login form, excluding "Signup" and stuff
        render :controller => 'login', :action => :user, :layout => 'lightbox'
      else
        @login_only = params[:show_login_only]
        render :controller => 'login', :action => :user
      end
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
  
  
  def forgot_password
    @reminder_sent = false
    @bad_user_save = false
    if ( params[:email] && (search_email = params[:email].strip.downcase) && (search_email != '') )
      if @user = User.find_by_email(search_email)
      	password = generate_key(8)
      	@user.password = Digest::SHA2.hexdigest(password)
      	
      	if @user.save 
					UserMailer.reset_password(@user, password).deliver
#          Delayed::Job.enqueue(ResetPasswordJob.new(@user, password), 1)

					@reminder_sent = true
				else
					@bad_user_save = true
				end
      else
        @bad_email = true
      end
		else
			if params[:email]
        @bad_email = true			
			end
    end
    
		unless params[:lightbox].nil?
			# If our request tells us not to display layout (in a lightbox, for instance)
			render :layout => 'lightbox'
		end
  
  end
      
  def logout
    reset_session #this is a built in rails method
    redirect_to :controller => 'application', :action => 'index'
    cookies.delete(:saved_user_id)
    cookies.delete(:salted_user_id)
    return true
  end

  #######
  private
  #######
  
  def set_view_variables
    @login_only = true if params[:login_only]

    # If the user just came from the stream viewer, he should see the get_access partial.
    if (session[:last_controller] == 'streamapi_streams' and session[:last_action] == 'view')
      @show_get_access = true
    else
      # Otherwise, just show the register partial
      @show_register = true
    end
    
    # If the user just came from buying stock and clicked Register, we should tell user#create to bring him back.
    if (session[:last_controller] == 'bands' and session[:last_action] == 'buy_stock' and session[:last_id])
      come_back_to = band_url(session[:last_id])
      logger.info "Telling user/create to redirect back to " + come_back_to + "."
      @redemption_redirect = come_back_to
    end
    
  end

end

