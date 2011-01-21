class LoginController < ApplicationController

  skip_filter :update_last_location
  skip_filter :update_last_controller_and_action, :only => :user  # Otherwise last_controller and last_action would be invalidated when the user is redirected to https/
  protect_from_forgery :only => [:process_user_login, :forgot_password]
  
  ssl_required :user, :process_user_login, :admin
  
  
  def user
    logger.info "LCU: #{ session[:last_clean_url] }"

    # Send to home page if user is already logged in.
    if session[:user_id]
      redirect_to :controller => 'users', :action => 'control_panel'
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
    if session[:user_id]
      flash[:error] = 'Already logged in.'
      redirect_to :controller => 'users', :action => 'control_panel', :lightbox => params[:lightbox]
      return false
    end
    
    #see if logging in from omniauth
    if session[:authentication_id]
      auth_id = session[:authentication_id]
      session[:authentication_id] = nil
      authentication = Authentication.find(auth_id)
      
      if authentication && authentication.user
        @user = authentication.user
      else
        flash[:notice] = "Could not log in properly. Please try again."
        render :controller => 'login', :action => 'user', :lightbox => params[:lightbox]
        return false
      end

            
    #else see if email and password sent          
    else
      if params[:user].nil? || params[:user][:email].nil? || params[:user][:password].nil?
        if params[:email].nil? || params[:password].nil?
          flash[:notice] = "Email and password not sent appropriately."
          render :controller => 'login', :action => :user, :lightbox => params[:lightbox]
          return false
        else
          passed_email = params[:email]
          passed_password = params[:password]
        end
      else
        passed_email = params[:user][:email]
        passed_password = params[:user][:password]
      end
      
      #see if the password matches, check salted and non-salted
      #see if it has been salted previously or not  (because salting was added in after users had already been in the system)
      if ( @user = User.find_by_email(passed_email) ) && (( @user.password_salt.blank? && @user.password == Digest::SHA2.hexdigest(passed_password) ) || (!@user.password_salt.blank? && @user.password == Digest::SHA2.hexdigest("#{@user.password_salt}#{passed_password}")))    
        #if the password is yet to be salted, salt it
        if @user.password_salt.blank?      
          #create salted password
          random = ActiveSupport::SecureRandom.hex(10)
          salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
          salted_password = Digest::SHA2.hexdigest("#{salt}#{passed_password}")

          @user.password_salt = salt
          @user.password = salted_password
          @user.save
        end
      #wrong password
      else
        flash[:error] = "Email and password do not match."
        @user = User.new(:email => passed_email)
        redirect_to :controller => 'login',
                    :action => :user,
                    :lightbox => params[:lightbox],
                    :show_login_only => params[:show_login_only]
        return false        
      end    
    end
    
    
    #log the user in
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
      redirect_to :controller => 'users', :action => 'control_panel', :lightbox => params[:lightbox]
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
      	#create salted password
        random = ActiveSupport::SecureRandom.hex(10)
        salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
        salted_password = Digest::SHA2.hexdigest("#{salt}#{password}")
      
        @user.password_salt = salt
        @user.password = salted_password
      	
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
    cookies.delete(:saved_user_id)
    cookies.delete(:salted_user_id)
    return true
    respond_to do |format|
      format.html redirect_to :controller => 'application', :action => 'index'
      format.json render :text => get_json
    end
  end
  
  #######
  private
  #######
  def get_json
    callback = params[:callback]
    json = {"html" => "success"}.to_json
    callback + "(" + json + ")"
  end
  def set_view_variables
    @login_only = true if (!params[:login_only].blank? or !params[:show_login_only].blank?)
    logger.info "Login only: #{@login_only}"

    # If the user just came from the stream viewer, he should see the get_access partial.
    if (!params[:show_get_access].blank? || (session[:last_controller] == 'streamapi_streams' and session[:last_action] == 'view'))
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

