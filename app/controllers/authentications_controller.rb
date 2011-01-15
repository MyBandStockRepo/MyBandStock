class AuthenticationsController < ApplicationController
 before_filter :authenticated?, :except => [:index, :create, :failure]
 skip_filter :update_last_location, :except => [:index]
  
  def failure
    if params[:message]
      flash[:error] = "Could not authenticate with third party network. #{params[:message].gsub(/[_]/, ' ')}"
    end

    #if coming from an external site (in the bar), redirect
    unless session[:extrenal_bar_registration].blank?      
      redirect_to :controller => "users", :action => "external_registration_error"
      return false
    end
    
    if session[:user_id]      
      redirect_to edit_user_path(session[:user_id])
    else
      redirect_to :controller => "login", :action => "user"
    end
  end
  
  def index    
    @user = User.find(session[:user_id]) if session[:user_id]
    @authentications = @user.authentications if @user  
  end
  
  
  def create
    omniauth = request.env["omniauth.auth"]
    if omniauth.blank? || omniauth['provider'].blank? || omniauth['uid'].blank?
      flash[:error] = "Could not get authentication parameters."  
            
      if session[:extrenal_bar_registration]
        redirect_to :controller => "users", :action => "external_registrtion_error"
      elsif session[:user_id]      
        redirect_to :controller => "users", :action => "connect_social_networks"
#        redirect_to edit_user_path(session[:user_id])
      else
        redirect_to :controller => "login", :action => "user"
      end
      return false            
    end

    #if coming from the external bar
    if session[:extrenal_bar_registration]
      # see if a current account in our system is tied into the provider
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      #if it is, send them to manual reg with an error
      if authentication
        flash[:error] = "Someone has already registered an account using that #{omniauth['provider']} account. Please manually register."
        redirect_to :controller => "users", :action => "external_registration"
        return false
      #if not, create this new auth and new account          
      else
        
        #auto gen password        
  			genpass = generate_key(16)
  			random = ActiveSupport::SecureRandom.hex(10)
        salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
        salted_password = Digest::SHA2.hexdigest("#{salt}#{genpass}")
                
        user = User.new(:password => salted_password, :status => 'pending', :password_salt => salt)
        authentication = user.apply_omniauth(omniauth, params)
        

        #if validation passes, log the user in
        if user.save            
          #create/update omniauth db info on login
          create_or_update_omniauth_service(omniauth, authentication, params)

          if user.twitter_user
            user.reward_tweet_bandstock_retroactively
          end
            
          band_registered_in = Band.find(session[:register_with_band_id])
          #SNED EMAIL
          UserMailer.register_through_bar(user, band_registered_in).deliver
          
          #AWARD POINTS
          if session[:register_with_band_id] && band_registered_in
            ShareLedgerEntry.create(:user_id => user.id, :band_id => band_registered_in.id, :adjustment => SHARES_AWARDED_DURING_BAR_REGISTRATION, :description => 'registered_from_bar')
          end

          flash[:notice] = "Account successfully created!"
          redirect_to :controller => "users", :action => "external_registration_success"
          return false
          
          
        #take them to a form to fill in information that is necessary
        else
          #HERE
          #have the new user model auto gen the password
          create_or_update_omniauth_service(omniauth, nil, params)
          facebook_id = omniauth['provider'].to_s.downcase == 'facebook' ? FacebookUser.find_by_facebook_id(omniauth['uid']) : nil
          twitter_id = omniauth['provider'].to_s.downcase == 'twitter' ? TwitterUser.find_by_twitter_id(omniauth['uid']) : nil
          user_hash = Hash.new
          user_hash[:first_name] = user.first_name
          user_hash[:last_name] = user.last_name
          user_hash[:email] = user.email
          user_hash[:facebook_id] = facebook_id
          user_hash[:twitter_id] = twitter_id
          user_hash[:provider] = omniauth['provider']
          user_hash[:uid] = omniauth['uid']
          session[:user_hash] = user_hash
          flash[:error] = "We need a little more information from you to complete registration."
          redirect_to :controller => 'users', :action => 'external_registration'
          return false
        end




      end
    end
    #end stuff for external bar

    if session[:user_id]      
      @user = User.find(session[:user_id])       
      
      #see if they already ahve an authentication with this provider
      unless @user.authentications.find_by_provider(omniauth['provider']).blank?
        flash[:error] = "You have already connected a #{omniauth['provider']} account to this MyBandStock account."  
#        redirect_to edit_user_path(session[:user_id])   
        redirect_to :controller => "users", :action => "connect_social_networks"
        return false      
      end      
    end
        
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    
    #authentication exists already, log user in
    if authentication
      if @user
        flash[:error] = "Sorry, this account has already been linked to another account."          
#        redirect_to edit_user_path(session[:user_id])   
        redirect_to :controller => "users", :action => "connect_social_networks"
        return false
      end
      session[:authentication_id] = authentication.id
      
      #create/update omniauth db info on login
      create_or_update_omniauth_service(omniauth, authentication, params)
      
      #log user in      
      redirect_to :controller => 'login', :action => 'process_user_login'
      
    #authentication doesn't exist, user logged in create auth and tie in to Facebook Users or Twitter Users
    elsif @user
      authentication = @user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])      

      #create/update omniauth db info on login
      create_or_update_omniauth_service(omniauth, authentication, params)
      
      if @user.twitter_user
        @user.reward_tweet_bandstock_retroactively
      end
      
      #award bandstock for tying into an account
      unless session[:authenticating_with_band_id].blank?
        authentication.award_bandstock_for_authenticating(session[:authenticating_with_band_id])
        session[:authenticating_with_band_id] = nil
      end
      
      
      
      flash[:notice] = "Authentication successful."  
#      redirect_to edit_user_path(session[:user_id])   
         redirect_to :controller => "users", :action => "connect_social_networks"     
    #Don't have a website account, redirect to new users
    else
      user = User.new
      authentication = user.apply_omniauth(omniauth, params)
      
      #if validation passes, log the user in
      if user.save
        session[:authentication_id] = authentication.id
        #create/update omniauth db info on login
        create_or_update_omniauth_service(omniauth, authentication, params)
        
        if user.twitter_user
          user.reward_tweet_bandstock_retroactively
        end
        
        #log user in      
        redirect_to :controller => 'login', :action => 'process_user_login'
        
      #take them to a form to fill in information that is necessary
      else
        create_or_update_omniauth_service(omniauth, nil, params)
        facebook_id = omniauth['provider'].to_s.downcase == 'facebook' ? FacebookUser.find_by_facebook_id(omniauth['uid']) : nil
        twitter_id = omniauth['provider'].to_s.downcase == 'twitter' ? TwitterUser.find_by_twitter_id(omniauth['uid']) : nil
        user_hash = Hash.new
        user_hash[:first_name] = user.first_name
        user_hash[:last_name] = user.last_name
        user_hash[:email] = user.email
        user_hash[:facebook_id] = facebook_id
        user_hash[:twitter_id] = twitter_id
        user_hash[:provider] = omniauth['provider']
        user_hash[:uid] = omniauth['uid']
        session[:user_hash] = user_hash
                
        redirect_to :controller => 'users', :action => 'new'
      end
    end 
  end


  
  def destroy
    @user = User.find(session[:user_id]) if session[:user_id]
    if @user
      @authentication = @user.authentications.find(params[:id]) 
      
      #remove the facebook and twitter auth ids
      if @authentication.provider.downcase == 'twitter'
        twitter_user = TwitterUser.find_by_authentication_id(@authentication.id)
        if twitter_user
          twitter_user.authentication_id = nil
          twitter_user.save
        end
        @user.twitter_user_id = nil
        @user.save
      elsif @authentication.provider.downcase == 'facebook'
        facebook_user = FacebookUser.find_by_authentication_id(@authentication.id)
        if facebook_user
          facebook_user.authentication_id = nil
          facebook_user.save
        end        
      end
      
      @authentication.destroy  
      flash[:notice] = "Successfully removed authentication."  
#      redirect_to edit_user_path(session[:user_id])   
        redirect_to :controller => "users", :action => "connect_social_networks"
    else
      flash[:notice] = "Could not get a User to delete their Authentication."
      redirect_to :controller => "login", :action => "user"
    end
  end
  
  private
  
  def create_or_update_omniauth_service(omniauth, authentication=nil, params=nil)
    create_or_update_facebook_user(omniauth, authentication, params)
    create_or_update_twitter_user(omniauth, authentication, params)
  end
  
  
  def create_or_update_facebook_user(omniauth, authentication=nil, params=nil)
    #--- FACEBOOK AUTH ---#
    if omniauth && omniauth['provider'] && omniauth['uid'] && omniauth['provider'].downcase == "facebook"
      #access token
      token = nil
      if params[:code]
        access_token = facebook_client.web_server.get_access_token(params[:code], :redirect_uri => facebook_redirect_uri)
        token = access_token.token
      end
      
      #user info
      name = nil
      location = nil
      gender = nil
      email = nil
      if omniauth['extra'] && omniauth['extra']['user_hash']
        if omniauth['extra']['user_hash']['name']
          name = omniauth['extra']['user_hash']['name']
        end
        if omniauth['extra']['user_hash']['location'] && omniauth['extra']['user_hash']['location']['name']
          location = omniauth['extra']['user_hash']['location']['name']
        end
        if omniauth['extra']['user_hash']['gender']
          gender = omniauth['extra']['user_hash']['gender']
        end
        if omniauth['extra']['user_hash']['email']
          email = omniauth['extra']['user_hash']['email']
        end
      end
           
      facebook_user = FacebookUser.find_by_facebook_id(omniauth['uid'])
  
      auth_id = nil
      if authentication && authentication.id
        auth_id = authentication.id
      end
  
      #if FacebookUser exists, update, else create
      if facebook_user.blank?
        FacebookUser.create(:facebook_id => omniauth['uid'], :name => name, :location => location, :email => email, :gender => gender, :access_token => token, :authentication_id => auth_id)          
      else
        if name
          facebook_user.name = name
        end
        if location
          facebook_user.location = location
        end
        if email
          facebook_user.email = email
        end
        if gender
          facebook_user.gender = gender
        end
        if token            
          facebook_user.access_token = token
        end
        if auth_id
          facebook_user.authentication_id = auth_id
        end
        facebook_user.save
      end
    end
    false
  end
  
  def create_or_update_twitter_user(omniauth, authentication=nil, params=nil)
    #--- TWITTER AUTH ---#        
    if omniauth && omniauth['provider'] && omniauth['uid'] && omniauth['provider'].downcase == "twitter"
      #oauth access token and secret
      token = nil
      secret = nil
      if omniauth['credentials']
        if omniauth['credentials']['token']
          token = omniauth['credentials']['token']
        end
        if omniauth['credentials']['secret']
          secret = omniauth['credentials']['secret']
        end          
      end
      
      #user info
      name = nil
      user_name = nil
      location = nil
      if omniauth['user_info']
        if omniauth['user_info']['name']
          name = omniauth['user_info']['name']
        end
        if omniauth['user_info']['location']
          location = omniauth['user_info']['location']
        end
        if omniauth['user_info']['nickname']
          user_name = omniauth['user_info']['nickname']
        end
      end     

      twitter_user = TwitterUser.find_by_twitter_id(omniauth['uid'])

      auth_id = nil
      if authentication && authentication.id
        auth_id = authentication.id
      end 

      #if a twitter user exists, update else create
      if twitter_user.blank?                
        TwitterUser.create(:twitter_id => omniauth['uid'], :name => name, :user_name => user_name, :location => location, :oauth_access_token => token, :oauth_access_secret => secret, :authentication_id => auth_id, :opt_out_of_messages => false)
      else
        #update only fields that are populated
        if name
          twitter_user.name = name
        end
        if user_name
          twitter_user.user_name = user_name
        end
        if location
          twitter_user.location = location
        end
        if token && secret
          twitter_user.oauth_access_token = token
          twitter_user.oauth_access_secret = secret
        end
        if auth_id
          twitter_user.authentication_id = auth_id
        end
        twitter_user.save
      end
    end
    false    
  end


  def facebook_client
   OAuth2::Client.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, :site => 'https://graph.facebook.com')
  end
  
  def facebook_redirect_uri
    uri = URI.parse(request.url)
    uri.path = '/auth/facebook/callback'
    uri.query = nil
    uri.to_s
  end
  
end

