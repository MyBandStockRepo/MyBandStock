class UsersController < ApplicationController

  protect_from_forgery :only => [:create, :update, :external_registration_complete]
  before_filter :authenticated?, :except => [:external_registration_success, :register_with_band_external, :external_registration, :external_registration_error, :external_registration_complete, :new, :create, :state_select, :activate, :register_with_twitter, :register_with_twitter_step_2, :clear_twitter_registration_session, :show], :unless => :api_call?
  before_filter :find_user, :only => [:edit, :address]
  # before_filter :authorize_api_access, :if => :api_call?, :only => :index
  # skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists, :manage_friends, :inbox, :purchases]
  skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists, :address], :unless => :api_call?
  before_filter :make_sure_band_id_session_exists, :only => [:external_registration]

  def external_registration_success
    session[:register_with_band_id] = nil
    session[:extrenal_bar_registration] = nil
    render :template => 'users/external/external_registration_success', :layout => 'white-label'    
  end
  
  
  def register_with_band_external
    #log out users
    reset_session #this is a built in rails method
    cookies.delete(:saved_user_id)
    cookies.delete(:salted_user_id)
    #end logout
    
    
    session[:test_cookies] = "doesthiswork?"
    unless session[:test_cookies] == "doesthiswork?"
      flash[:error] = "Cookies must be enabled to register."
      redirect_to :controller => "application", :action => "external_error"
      return false      
    end
    #no band id specified, halt the registration
    if params[:band_id].blank?
      flash[:error] = "Could not find the artist you are registering with."
      redirect_to :controller => "application", :action => "external_error"
      return false
    end
    @band = Band.find(params[:band_id])
    if @band.blank?
      flash[:error] = "Could not find the artist you are registering with."
      redirect_to :controller => "application", :action => "external_error"
      return false      
    end
    
    session[:register_with_band_id] = @band.id
    session[:extrenal_bar_registration] = true
#DEBUGGING
    logger.info "External bar: #{session[:extrenal_bar_registration]}"
    logger.info "BAND ID: #{session[:register_with_band_id]} for band #{@band.name}"
#DEBUGGING END    
    #if the mode of registration not specified, have them do a normal registration
    if params[:mode].blank?
      redirect_to :controller => "users", :action => "external_registration"
      return
    end
    
    if params[:mode].downcase == "facebook"
      redirect_to "/auth/facebook"      
      return
    end    
  end
  
  def external_registration
    #DEBUGGING
        logger.info "External bar: #{session[:extrenal_bar_registration]}"
        logger.info "BAND ID: #{session[:register_with_band_id]}"
    #DEBUGGING END    
    
    if session[:user_hash]
      user_hash = session[:user_hash]
      if params[:user]   
        @user = User.new(params[:user])
      else
        @user = User.new(:first_name => user_hash[:first_name], :last_name => user_hash[:last_name], :email => user_hash[:email], :email_confirmation => user_hash[:email])
      end
      @provider = user_hash[:provider]
      @uid = user_hash[:uid]
    elsif params[:user]   
      @user = User.new(params[:user])
    else
      @user = User.new()
    end
        
    render :template => 'users/external/external_registration', :layout => 'white-label'
    return
  end
  
  def external_registration_error
    render :template => 'users/external/external_registration_error', :layout => 'white-label'    
    #DEBUGGING
        logger.info "External bar: #{session[:extrenal_bar_registration]}"
        logger.info "BAND ID: #{session[:register_with_band_id]}"
    #DEBUGGING END
    return

  end
  #the post
  def external_registration_complete  
    #DEBUGGING
        logger.info "External bar: #{session[:extrenal_bar_registration]}"
        logger.info "BAND ID: #{session[:register_with_band_id]}"
    #DEBUGGING END    
    @success = false
    #if register through omniauth
    if session[:user_hash]
      user_hash = session[:user_hash]
      @facebook_user = nil
      @twitter_user = nil
      @provider = user_hash[:provider]
      @uid = user_hash[:uid]
      
      #note still have to save auth id into fb/twitter users table
      if user_hash[:facebook_id] && @facebook_user = FacebookUser.find(user_hash[:facebook_id])
        
      elsif user_hash[:twitter_id] && @twitter_user = TwitterUser.find(user_hash[:twitter_id])

      end
      if params[:user]            
        user_registration_info = params[:user]
      else
        user_registration_info = session[:user_hash]
      end
    #if theyve been here before
    elsif params[:user]
      user_registration_info = params[:user]
      
    else
      flash[:error] = "Could not get parameters to register an account."
      redirect_to :controller => "users", :action => "external_registration_error"
      return false
    end
    @user = User.new(user_registration_info)
    genpass = generate_key(16)
		random = ActiveSupport::SecureRandom.hex(10)
    salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
    salted_password = Digest::SHA2.hexdigest("#{salt}#{genpass}")
    @user.password = salted_password
    @user.password_salt = salt
    @user.email_confirmation = @user.email
    if (@user.save)            
      #if from omniauth, save the authentication and connect to the twitter/facebook user
      if session[:user_hash]
        user_hash = session[:user_hash]
        auth = @user.authentications.create(:provider => user_hash[:provider], :uid => user_hash[:uid])
        if user_hash[:facebook_id] && @facebook_user = FacebookUser.find(user_hash[:facebook_id])
          @facebook_user.authentication_id = auth.id
          @facebook_user.save
        elsif user_hash[:twitter_id] && @twitter_user = TwitterUser.find(user_hash[:twitter_id])
          @twitter_user.authentication_id = auth.id
          @twitter_user.save
        end
      end
      
      @band = Band.find(session[:register_with_band_id])
      if @band.blank?
        flash[:error] = "Could not determine which band you are registering with"
        redirect_to :controller => "users", :action => "external_registration_error"
        return false
      end
      
      
      #SNED EMAIL
      UserMailer.register_through_bar(@user, @band).deliver
      
      #AWARD POINTS
      if session[:register_with_band_id] && @band
        ShareLedgerEntry.create(:user_id => @user.id, :band_id => @band.id, :adjustment => SHARES_AWARDED_DURING_BAR_REGISTRATION, :description => 'registered_from_bar')
      end      
      
      
      #reset session data
      session[:user_hash] = nil
      session[:user_id] = @user.id
      
      @success = true

      
      #award twitter bandstock
      if @user.twitter_user
        @user.reward_tweet_bandstock_retroactively
      end      
      flash[:notice] = "Account successfully created!"
      redirect_to :controller => "users", :action => "external_registration_success"
      return
    else
      error_text = "An error prevented this user from completing registration. Email: "
      cnt = 0
      for e in @user.errors[:email]
        if cnt > 0
          error_text += ", #{e}"
        else
          error_text += " #{e}"
        end
        cnt +=1
      end
      flash[:error] = error_text
      
			redirect_to :controller => "users", :action => "external_registration", :user => @user
      return
    end
    
    
    
    # Hash the password before putting it into DB


      
      
    
    
    #if from manual registration

      #autogen password
    
      #try to save user
    
    #if failure, go back to the form  
  end
  def index
    if params[:band_id] 
      @band = Band.find(params[:band_id])
      if params[:email] || (params[:salt]) 
        login_or_create_user
      end 
      @shareholders = @band.shareholders
      (@share_total = ShareTotal.get_with_band_and_user_ids(@band.id, @user.id)) if @band && @user
      @net = @share_total.nil? ? "0" : @share_total.net
    else
      return false #we should redirect somewhere
    end
    respond_to do |format|
      format.html
      format.json {render :text => get_jsonp } 
      format.xml { render :xml => [@user.api_attributes.to_xml, @share_total.to_xml] }
    end
  end
  
  
  def show
    unless (@user = User.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end
=begin    
    @top_friends = @user.top_friends
    @top_invested_artists = @user.top_invested_artists
    
=end    
#    @random_band = get_random_band()
    respond_to do |format|
      format.html
      format.js
      format.xml
    end    
  end
  
  def register_with_twitter
    if params[:band_id] && Band.find(params[:band_id])
      session[:register_and_redirect_to_band_id] = params[:band_id]
    else
      session[:register_and_redirect_to_band_id] = nil
    end
  end
  
	def activate
		if params[:user_id] && params[:code]
			lookup_user = User.find(params[:user_id])
						
			if lookup_user			  
			  #check that password matches
			  if (lookup_user.password_salt.blank? && lookup_user.password == Digest::SHA2.hexdigest(params[:code])) || (!lookup_user.password_salt.blank? && lookup_user.password == Digest::SHA2.hexdigest("#{lookup_user.password_salt}#{params[:code]}"))
  				if lookup_user.status == 'pending'
  					log_user_in(lookup_user.id)
  					redirect_to :action => 'edit'
  				else
  					flash[:error] = 'This account has already been activated.'
  					redirect_to :controller => :login, :action => :user, :lightbox => params[:lightbox]
  					return false							
  				end
  			else
  				flash[:error] = 'Incorrect activation code. Please try again.'
  				redirect_to root_url
  				return false
			  end
			else
				flash[:error] = 'Could not find user with the given email and code.'
				redirect_to root_url
				return false			
			end
		else
			flash[:error] = 'Could not get correct number of parameters for activation.'
			redirect_to root_url			
			return false
		end
	end
  
  def edit
		@request_uri = url_for()

    unless (id = params[:id])
      id = session[:user_id]
    else
      unless ( (id != session[:user_id]) && (User.find(session[:user_id]).site_admin) )
        id = session[:user_id]
      end
    end
    
    @user = User.find(id)
    @authentications = @user.authentications if @user
    fb = @user.authentications.where(:provider => 'facebook').first
    if fb
      @facebook_user = FacebookUser.find_by_authentication_id(fb.id)
    else
      @facebook_user = nil
    end
    twit = @user.authentications.where(:provider => 'twitter').first    
    if twit
      @twitter_user = TwitterUser.find_by_authentication_id(twit.id)
    else
      @twitter_user = nil
    end
        
    # Clear password field for editing
		@user.email_confirmation = @user.email    
    
    
    unless @user.country_id.nil?
      @states = State.find_all_by_country_id(@user.country_id)
    else
      @states = nil
    end
    
    @user_is_pending = true if @user.status == 'pending'
    
		begin
			unless @user.authenticated_with_twitter?
				@user_twitter_authorized = false
			else
				@twit_user = @user.twitter_client.verify_credentials
				@user_twitter_authorized = true										
			end		
		rescue
				@user_twitter_authorized = false
		end    
    
    
    render :layout => 'lightbox' unless params[:lightbox].nil?
  end
  
  def address
  end
  
  # Update the specified user record. Expects the same input format as the #create action.
  def update
    unless ( (id = params[:id]) && ( (id == session[:user_id]) || (User.find(session[:user_id]).site_admin) ) )
      id = session[:user_id]
    end
    @user = User.find(id)
    @authentications = @user.authentications if @user  
    
    fb = @user.authentications.where(:provider => 'facebook').first
    if fb
      @facebook_user = FacebookUser.find_by_authentication_id(fb.id)
    else
      @facebook_user = nil
    end
    twit = @user.authentications.where(:provider => 'twitter').first    
    if twit
      @twitter_user = TwitterUser.find_by_authentication_id(twit.id)
    else
      @twitter_user = nil
    end    
    
		@request_uri = edit_user_url(id)
    @user.email_confirmation = params[:user][:email_confirmation]
		begin
			unless @user.authenticated_with_twitter?
				@user_twitter_authorized = false
			else
				@twit_user = @user.twitter_client.verify_credentials
				@user_twitter_authorized = true										
			end		
		rescue
				@user_twitter_authorized = false
		end    
    
    
    # if they have flipped whether they want messages or not
		if @user.twitter_user && params[:twitter_user] && params[:twitter_user][:twitter_replies] && ((params[:twitter_user][:twitter_replies] == "0" && @user.twitter_user.opt_out_of_messages == false) ||(params[:twitter_user][:twitter_replies] == "1" && @user.twitter_user.opt_out_of_messages == true))
		  tw_user = @user.twitter_user
		  tw_user.opt_out_of_messages = !tw_user.opt_out_of_messages
		  tw_user.save
	  end
		
    
    
		# Hash the password before putting it into DB
		
		if params[:user] && params[:user][:password] && params[:user][:password] != '' && params[:user][:password] != nil
		  
		  #see if a salt exists
      random = ActiveSupport::SecureRandom.hex(10)
      salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
      salted_password = Digest::SHA2.hexdigest("#{salt}#{params[:user][:password]}")
      params[:user][:password_salt] = salt
			params[:user][:password] = salted_password
		else
			if @user.status == 'pending'
				#set password to nil if user is activating so that they are required to put a password
				params[:user][:password] = nil
			else
				params[:user][:password] = @user.password
			end
		end


		# We must also hash the confirmation entry so the model can check them together
        
    #for the regular "post"ers make sure the country matches the state in case they changed it
    unless ( params[:user][:country_id].nil? || (params[:user][:country_id].to_i == @user.country_id) || (params[:user][:state_id] == '1') )
      unless Country.find(params[:user][:country_id]).states.collect{|s| s.id}.include?(params[:user][:state_id].to_i)
      #if the state isn't in the country then reset the state_id update and redirect
      params[:user][:state_id] = 1

      @user.update_attributes(params[:user])
      if @user.twitter_user
        @user.reward_tweet_bandstock_retroactively
      end
      redirect_to :action => "state_select"
      return true
      end
    end
    
    if params[:user][:phone]
      params[:user][:phone].gsub!(/[^0-9]/, '')#clean phone
    end
    @user.update_attributes(params[:user])
    
    success = @user.save
    if @user.twitter_user
      @user.reward_tweet_bandstock_retroactively
    end
    if success
			if @user.status == 'pending'
				@user.status = 'active'
			end
			
			success = @user.save
		end    
    
    respond_to do |format|
      format.html { 
                    unless success #&& photo_success
                      render :action => 'edit'
                      return false
                    else
                      flash[:notice] = "Profile updated."
                      redirect_to root_url
                    end
                  }
      format.js
      format.xml  { head :ok }
    end

  end

  def clear_twitter_registration_session
    session[:quick_registration_twitter_user_id] = nil
    #clear omniauth
    session[:user_hash] = nil
    redirect_to :controller => 'users', :action => 'new', :redemption_redirect => params[:redemption_redirect]
  end

  def new
    #coming from omniauth
    if session[:user_hash]
      user_hash = session[:user_hash]
#      session[:user_hash] = nil
      @facebook_user = nil
      @twitter_user = nil
      @omniauth = true
      @provider = user_hash[:provider]
      @uid = user_hash[:uid]
      
      #note still have to save auth id into fb/twitter users table
      if user_hash[:facebook_id] && @facebook_user = FacebookUser.find(user_hash[:facebook_id])
        
      elsif user_hash[:twitter_id] && @twitter_user = TwitterUser.find(user_hash[:twitter_id])

      end

      #check to see if they've been around before
      if params[:user]   
        @user = User.new(params[:user])
      else
        @user = User.new(:first_name => user_hash[:first_name], :last_name => user_hash[:last_name], :email => user_hash[:email], :email_confirmation => user_hash[:email])
      end


    #clicked new account button
    else
  		@request_uri = url_for()  

      #check to see if they've been around before
      if params[:user]
        @user = User.new(params[:user])        
      else
        @user = User.new
      end
    
  		begin
  			unless @user.authenticated_with_twitter?
  				@user_twitter_authorized = false
  			else
  				@twit_user = @user.twitter_client.verify_credentials
  				@user_twitter_authorized = true										
  			end		
  		rescue
  				@user_twitter_authorized = false
  		end    
      if (@user.country_id.nil? || @user.country_id == '' )
        #calculate their ip number to determine country of origin
        ip_parts = request.remote_ip.split(".")
        ipnum = 16777216*ip_parts[0].to_i + 65536*ip_parts[1].to_i + 256*ip_parts[2].to_i + ip_parts[3].to_i 
        c_ip = CountryIp.find(:first, :conditions => ["begin_num < ? AND end_num > ?", ipnum, ipnum])
        unless c_ip.nil?
          if user_country = Country.find_by_name(c_ip.name.upcase)
            @user.country_id = user_country.id
          end
        end
        #update the states list
        state_select(@user.country_id)
      end
    
      unless params[:lightbox].nil?
        render :layout => 'lightbox'
      end
    end
  end
      
  
  def state_select(passed_country_id = nil)
    c_id = nil
    if passed_country_id
      c_id = passed_country_id
    elsif (params[:user] && params[:user][:country_id])
      @user_search = User.new(params[:user])
      c_id = params[:user][:country_id]
    elsif params[:country_id]
      c_id = params[:country_id]
    elsif session[:user_registration_info] && session[:user_registration_info][:country_id]
      @user_search = User.new(session[:user_registration_info])
      c_id = session[:user_registration_info][:country_id]
    elsif (@user_search = User.find_by_id(session[:user_id]))
      c_id = @user_search.country_id
    end

    @states = State.find_all_by_country_id( c_id )
  end
  
  
  def create    
    #check to see if they've posted
    if params[:user]
      #so they have posted to us, filter the posted data
      session[:user_registration_info] = params[:user]
      user_registration_info = params[:user]
    elsif session[:user_registration_info] #check to see if they've got goodies in session
      user_registration_info = session[:user_registration_info]
    else
      #they don't have session data and they haven't posted to us so get em out of here
      flash[:notice] = "Something went wrong, please try registering again."
      redirect_to :action => "new", :lightbox => params[:lightbox]
    end

    #if register through omniauth
    if session[:user_hash]
      user_hash = session[:user_hash]
      @facebook_user = nil
      @twitter_user = nil
      @omniauth = true
      @provider = user_hash[:provider]
      @uid = user_hash[:uid]
      
      #note still have to save auth id into fb/twitter users table
      if user_hash[:facebook_id] && @facebook_user = FacebookUser.find(user_hash[:facebook_id])
        
      elsif user_hash[:twitter_id] && @twitter_user = TwitterUser.find(user_hash[:twitter_id])

      end      
    end



    # Hash the password before putting it into DB
    if user_registration_info[:password] && !user_registration_info[:password].nil? && user_registration_info[:password] != ''
      random = ActiveSupport::SecureRandom.hex(10)
      salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
      salted_password = Digest::SHA2.hexdigest("#{salt}#{user_registration_info[:password]}")
			user_registration_info[:password] = salted_password
			user_registration_info[:password_salt] = salt
		end
    # We must also hash the confirmation entry so the model can check them together
#    user_registration_info[:password_confirmation] = #needs work if we have the confirmation again Digest::SHA2.hexdigest(user_registration_info[:password_confirmation])
   
    #we can assume at this point that we've got something ready to authenticate in user_registration_info
    @user = User.new(user_registration_info)

    if (@user.save)
      #clear out the session
      session[:user_registration_info] = nil
      
      #if from omniauth, save the authentication and connect to the twitter/facebook user
      if session[:user_hash]
        user_hash = session[:user_hash]
        auth = @user.authentications.create(:provider => user_hash[:provider], :uid => user_hash[:uid])
        if user_hash[:facebook_id] && @facebook_user = FacebookUser.find(user_hash[:facebook_id])
          @facebook_user.authentication_id = auth.id
          @facebook_user.save
        elsif user_hash[:twitter_id] && @twitter_user = TwitterUser.find(user_hash[:twitter_id])
          @twitter_user.authentication_id = auth.id
          @twitter_user.save
        end
      end
      
      
      session[:user_hash] = nil
      session[:user_id] = @user.id
      flash[:notice] = "Registration successful."
      session[:auth_success] = true
      session[:quick_registration_twitter_user_id] = nil
      
      UserMailer.registration_notification(@user).deliver
      if @user.twitter_user
        @user.reward_tweet_bandstock_retroactively
      end
      # send email to new users welcoming to website, priority -1, default is 0
#      Delayed::Job.enqueue(RegistrationNotificationJob.new(@user), -1)
      
      if !params[:redemption_redirect].blank?
        redirect_url = params[:redemption_redirect] + '&user_id=' + @user.id.to_s
        logger.info "Redirecting to " + redirect_url
      	redirect_to redirect_url
#      elsif session[:last_clean_url]
#      	redirect_to session[:last_clean_url], :lightbox => params[:lightbox]
      else
        if session[:register_and_redirect_to_band_id] && Band.find(session[:register_and_redirect_to_band_id])
          redirect_to :controller => 'bands', :action => 'show', :id => session[:register_and_redirect_to_band_id]
          session[:register_and_redirect_to_band_id] = nil
        else
          if session[:last_clean_url]
  				  redirect_to session[:last_clean_url], :lightbox => params[:lightbox]
          else
  				  redirect_to '/me/control_panel', :lightbox => params[:lightbox]
				  end
        end

      end
      
			return
      
    else
      state_select(@user.country_id)
      @user.password = ''
#      @user.password_confirmation = ''
			if params[:lightbox].nil?
				render :action => :new, :redemption_redirect => params[:redemption_redirect]
			else
				render :action => :new, :layout => 'lightbox', :redemption_redirect => params[:redemption_redirect]
			end
      return
    end
    
    respond_to do |format|
      # If we're in HTML mode, redirect back to the master list.
      format.html { redirect_to edit_user_url(@user) }
      # If we're in XML mode, just return a 201 Created response.
      format.xml { head :created, :location => user_path(@user) }
    end
  end
  
  
  def membership
  #this action shows all the bands a user is a part of
    @user = User.find(params[:id])
    @user_bands = Band.find( @user.associations.find_all_by_name('member').collect {|a| a.band_id} )
  end
  
  
  def toggle_band_watching
    unless @assoc = Association.find_by_user_id_and_band_id_and_name(session[:user_id], params[:id], 'watching')
      #create the association
      if band = Band.find_by_id(params[:id])
        Association.new do |a|
          a.user_id = session[:user_id]
          a.band_id = params[:id]
          a.name = 'watching'
          a.save
        end
      end
    else
      #destroy the existing association
      @assoc.destroy
    end
        
        
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js   {
                    unless params[:remove_div]
                      url_hash = {:controller => 'users', :action => 'toggle_band_watching', :id => params[:id]}
                      unless @assoc #unless the association was just destroyed
                        render :inline => "=link_to_remote '<strong>Remove</strong>', {:update => 'add', :url =>  url_hash }, {:class => 'remove', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                      else #if it was just destroyed
                        render :inline => "=link_to_remote '<strong>Watch</strong>', {:update => 'add', :url => url_hash }, {:class => 'add', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                      end
                      return true
                    else
                      #let the rjs render
                    end
                  }
                 
    end
    
  end
  
  
  
  
  
  
  #************************
  #  USER Control Panel STUFF
  #************************

  def control_panel
    # This is for the user's landing / main page. He sees some basic user editing stuff.
    #  If the user is a manager of one or more bands, he sees management listings for each band.
    authenticated?
    @user = User.find(session[:user_id])
	
    flash[:error] = flash[:error]
    flash[:notice] = flash[:notice]	
    
    # @bands is an array of band objects, or an empty array (never nil)
    if @user.site_admin
      @bands = Band.includes(:live_stream_series => :streamapi_streams).all
    else
      @bands = @user.bands.includes(:live_stream_series => :streamapi_streams) #.order('bands.id ASC, live_stream_series.id ASC, streamapi_streams.starts_at ASC')
    end
		
		if @bands.count == 0
			redirect_to :controller => 'bands', :action => 'index'
		end    
  end
  

protected

=begin
  def get_random_band()
    #this gets a random band playlist w/o dying 
    random_band = nil
    unless (Band.count == 0)
      for i in 1..10
        offset = rand(Band.count)
        random_band = Band.find(:first, :joins => :songs, :conditions => ['hidden = ?', false], :offset => offset)
        unless (random_band.nil? || random_band.playlist_songs.empty?)
          break
        end
      end
    end
    return (random_band || Band.new)
  end
=end
  
  def make_sure_band_id_session_exists
    #no band id specified, halt the registration
    if session[:register_with_band_id].blank?
      flash[:error] = "Could not find the artist you are registering with."
      redirect_to :controller => "application", :action => "external_error"
      return false
    end
    @band = Band.find(session[:register_with_band_id])
    if @band.blank?
      flash[:error] = "Could not find the artist you are registering with."
      redirect_to :controller => "application", :action => "external_error"
      return false      
    end      
  end
  
  def find_user
    unless (id = params[:id])
      id = session[:user_id]
    else
      unless ( (id != session[:user_id]) && (User.find(session[:user_id]).site_admin) )
        id = session[:user_id]
      end
    end
    
    @user = User.find(id)
  end
  def get_jsonp
    callback = params[:callback]
    if @no_user
      data = ""
      message = "delete"
    elsif !@authentic && @need_password #we found the user with this email, now we need a password to authenticate
      data = need_password_html(@user.email)
    elsif @authentic && !@need_password #the user is authenticated, we don't need the password, we return all the info for the user, including the salt to set the cookie
      data = logged_in_info(@user)
      message = @user.password_salt
    elsif params[:password] && !params[:password].blank? && params[:password] != "undefined" && !@authentic && !@need_password #all variations of why we'd need a new password try
      data = wrong_password(@user.email)
    elsif !@authentic && !@need_password #We didn't find a user with that email, so we created a new one and sent them a confirmation email.
      data = new_user_message(@user.email)
    end
    message ||= ""
    json = {"html" => data, "msg" => message}.to_json
    callback + "(" + json + ")"
  end
  
  def login_or_create_user
    @no_user = false
    @authentic = false
    @need_password = false
    if params[:salt] && params[:salt] != 'undefined'
      @user = User.where("password_salt = ?", params[:salt]).first
      @authentic = true if @user
      @no_user = true unless @user
    end
    @user = User.where("email = ?", params[:email]).first if params[:email]
    if @user
      if params[:password] && !params[:password].blank? && params[:password] != "undefined"
        if User.authenticate(params[:email], params[:password])
          @authentic = true
        else
          @authentic = false
        end
      else
        @need_password = !@authentic
      end
    else
      create_new_user
    end 
  end
  def create_new_user
    if @user = User.new(:email => params[:email], :password => generate_key(8))
      @user.generate_or_salt_password(@user.password)
      @user.save
    end
  end
  def need_password_html(email)
    "<div class =\"bar-login\">
      <span class=\"email\"style=\"display:none;\">
        Email: <input id=\"user_email\"name=\"user[email]\" size=\"30\" type=\"text\" value=\"#{email}\" />
      </span>
      Please enter your
      <span class=\"pass\"> 
        Password: <input id=\"user_password\" name=\"user[password]\" size=\"20\" type=\"password\" value=\"\" />
      </span>
    </div>"
  end
  def logged_in_info(user)
    "<p class=\"welcome\">Hi #{user.first_name}!</p>
    <div id=\"stats\">
      <p class=\"shares\">You have #{@net} shares!</p>
      <span class=\"logout-link\">logout</span>
    </div>
    "
  end
  def wrong_password(email)
    "<p class=\"message\">Sorry, wrong password, please try again" + need_password_html(email) + "</p>"
  end
  def new_user_message(email)
    "<p class=\"message\">Welcome, start collecting stock for #{@band.name} now and start receiving rewards. We sent you an email with more info.</p>"
  end
end #end controller
