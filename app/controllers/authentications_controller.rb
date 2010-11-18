class AuthenticationsController < ApplicationController
 before_filter :authenticated?, :except => [:index, :create]
 skip_filter :update_last_location, :except => [:index]

  
  def failure
    if params[:message]
      flash[:error] = params[:message].gsub(/[_]/, ' ')
    end
    redirect_to authentications_url
  end
  
  def index    
    @user = User.find(session[:user_id]) if session[:user_id]
    @authentications = @user.authentications if @user  
  end
  
  def create
    omniauth = request.env["omniauth.auth"]
    if omniauth.blank? || omniauth['provider'].blank? || omniauth['uid'].blank?
      flash[:error] = "Could not get authentication parameters."  
      redirect_to authentications_url
      return false            
    end

    puts omniauth.to_yaml

    if session[:user_id]
      @user = User.find(session[:user_id])       
      
      #see if they already ahve an authentication with this provider
      unless @user.authentications.find_by_provider(omniauth['provider']).blank?
        flash[:error] = "You have already connected a #{omniauth['provider']} account to this MyBandStock account."  
        redirect_to authentications_url
        return false      
      end      
    end
        
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    
    #authentication exists already, log user in
    if authentication
      if @user
        flash[:error] = "Sorry, this account has already been linked to another account."  
        redirect_to authentications_url        
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

      flash[:notice] = "Authentication successful."  
      redirect_to authentications_url
      
    #Don't have a website account, redirect to new users
    else
      user = User.new
      authentication = user.apply_omniauth(omniauth, params)
      
      #if validation passes, log the user in
      if user.save
#        authentication = user.authentications.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])      

        session[:authentication_id] = authentication.id
        #create/update omniauth db info on login
        create_or_update_omniauth_service(omniauth, authentication, params)
        #log user in      
        redirect_to :controller => 'login', :action => 'process_user_login'
        
      #take them to a form to fill in information that is necessary
      else
        #session[:omniauth] = omniauth.except('extra')
#        puts "#{user.to_yaml}"
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
      @authentication.destroy  
      flash[:notice] = "Successfully destroyed authentication."  
      redirect_to authentications_url
    else
      flash[:notice] = "Could not get a User to delete their Authentication."
      redirect_to authentications_url
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

