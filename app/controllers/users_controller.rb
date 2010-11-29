class UsersController < ApplicationController

 protect_from_forgery :only => [:create, :update]
 before_filter :authenticated?, :except => [:new, :create, :state_select, :activate, :register_with_twitter, :register_with_twitter_step_2, :clear_twitter_registration_session, :show]
						# skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists, :manage_friends, :inbox, :purchases]
 skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists]

  def index
    #What do we do with this action?
    redirect_to session[:last_clean_url]
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
  #		@newform = true
      @user = User.new
      #check to see if they've been around before
      if params[:user]
        @user = User.new(params[:user])
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
  
=begin
  def auto_complete_for_recipient_band_name
    unless ( (params[:recipient] && (band_name_search = params[:recipient][:band_name]) ) && (band_name_search.length >= 2) )
      render :nothing => true
      return false
    end
    
    @bands = Band.find(:all, :conditions => ['name LIKE ?', "%#{band_name_search}%"], :limit => 15)

    respond_to do |format|
      format.html {
                    render :nothing => true
                  }
      format.js   {
                    #dont like calling render in the code but it is what it is
                    render :partial => 'band_mails/band_recipient_autocomplete', :locals => {:band_collection => @bands}
                  }
    end
    
  end
  
=end  
  def control_panel
    # This is for the user's landing / main page. He sees some basic user editing stuff.
    #  If the user is a manager of one or more bands, he sees management listings for each band.
    authenticated?
    @user = User.find(session[:user_id])

    # @bands is an array of band objects, or an empty array (never nil)
    @bands = @user.bands.includes(:live_stream_series => :streamapi_streams) #.order('bands.id ASC, live_stream_series.id ASC, streamapi_streams.starts_at ASC')

		
		if @bands.count == 0
			redirect_to :controller => 'bands', :action => 'index'
		end
  end
  
=begin  
  def manage_artists
    unless ( @user = User.find_by_id(session[:user_id], :joins => {:earned_perks => {:google_checkout_order => :contributions}}) )
      @user = User.find(session[:user_id]) #the above is done for bringing data out with inner joins for better performance.  Although since I use joins, when a user cant fill one of those join models it returns nil.  so we have to be careful.
    end
    
    @total_shares = @user.total_shares
    @total_friends = @user.friends.size
    @user_net_worth = @user.net_worth
    @number_of_invested_artists = @user.invested_artists.size
    @prospective_artists = Band.find_all_by_id( @user.associations.find(:all, :conditions => ['name = ?', 'watching']).collect{|a| a.band_id} )
    
    @random_band = get_random_band()

  end  
=end  
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
  

end #end controller
