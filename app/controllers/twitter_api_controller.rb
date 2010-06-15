class TwitterApiController < ApplicationController
	protect_from_forgery :only => [:create, :update, :create_band, :post_retweet]
	before_filter :authenticated?, :except => [:index, :band_index, :show, :mentions, :favorites]
	
	def create_session
		begin
			@user = User.find(session['user_id'])
			
			redirect = session[:last_clean_url]
			
			if params[:redirect_url]
				redirect = url_for(params[:redirect_url])
				puts 'REDIRECT TO: '+redirect
			end
			
			
			
			oauth = Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY)
			oauth.set_callback_url(SITE_URL+'/twitter/finalize/?redirect='+redirect)
			request_token = oauth.request_token
			
			access_token = request_token.token
			access_secret = request_token.secret
			auth_url = request_token.authorize_url
	
			session['rtoken'] = access_token
			session['rsecret'] = access_secret
			
			if @user.bands.count && params[:band_id]
				if @user.has_band_admin(params[:band_id]) || @user.is_member_of_band(params[:band_id])
					session['band_id_for_twitter'] = params[:band_id]
					redirect_to auth_url
				else
						flash[:error] = 'You are not authorized to make changes for this band.  You need to be a band admin or member to authorize their Twitter account with our service.'
						session['band_id_for_twitter'] = nil					
						redirect_to session[:last_clean_url]
				end
			else
				session['band_id_for_twitter'] = nil
				redirect_to auth_url
			end
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			session['rtoken'] = session['rsecret'] = nil
			return false
		end		
	end
	
	
	def finalize
	
		begin
			unless params[:oauth_verifier]
				redirect_to :controller => 'social_networks', :action => 'index', :band_short_name => Band.find(session['band_id_for_twitter']).short_name
				session['rtoken'] = session['rsecret'] = session['band_id_for_twitter'] = nil			
				return false
			end
			unless session['rtoken'].nil? || session['rsecret'].nil?
				if session['band_id_for_twitter']
					band_oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
					profile = Twitter::Base.new(band_oauth).verify_credentials
					@band = Band.find(session['band_id_for_twitter'])
					
					#see if twitter account already exists
					existing_twitter = TwitterUser.where(:twitter_id => profile.id).first
					
					if existing_twitter
						twitter_user = existing_twitter
					else
						unless twitter_user = TwitterUser.create(:name => profile.name, :user_name => profile.screen_name, :twitter_id => profile.id, :oauth_access_token => band_oauth.access_token.token, :oauth_access_secret => band_oauth.access_token.secret)
							flash[:error] = 'Could not create Twitter user.'
						end
					end				
				
					@band.twitter_user_id = twitter_user.id
					unless @band.save
						flash[:error] = 'Could not update band database with Twitter keys.'
					end								
				else
					user_oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
					profile = Twitter::Base.new(user_oauth).verify_credentials				
					@user = User.find(session['user_id'])
	
					#see if twitter account already exists
					existing_twitter = TwitterUser.where(:twitter_id => profile.id).first
	
					if existing_twitter				
						twitter_user = existing_twitter
					else
						unless twitter_user = TwitterUser.create(:name => profile.name, :user_name => profile.screen_name, :twitter_id => profile.id, :oauth_access_token => user_oauth.access_token.token, :oauth_access_secret => user_oauth.access_token.secret)					
							flash[:error] = 'Could not create Twitter user.'
						end
					end				
									
					@user.twitter_user_id = twitter_user.id
					unless @user.save
						flash[:error] = 'Could not update user database with Twitter keys.'
					end					
				end	
			else			
				flash[:error] = 'Could not find Twitter request token or secret.'
			end
			if params[:redirect]


				path = params[:redirect]
				params.delete(:redirect)
				params.delete(:oauth_verifier)
				params.delete(:oauth_token)
				params.delete(:action)
				params.delete(:controller)
				paramsarr = params.to_a
				if params.count > 0
					path = path.to_s + '&' + paramsarr.collect{ |a| a.join('=')}.join('&')
				else
					path = path.to_s
				end
				# send all params that came  with the redirect address
				redirect_to path
			else
				redirect_to root_path
			end
			
			session['rtoken'] = session['rsecret'] = session['band_id_for_twitter'] = nil
		rescue
			session['rtoken'] = session['rsecret'] = session['band_id_for_twitter'] = nil
    	flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
    	redirect_to params[:redirect]
			return false
    end
	end

def update

end


	def retweet
		begin
			if @retweeter = User.find(session[:user_id]).twitter_user
				if params[:tweet_id] && params[:band_id]
					@tweet = client.status(params[:tweet_id])
					@tweeter = @tweet.user
					@band = Band.find(params[:band_id])
					if @band && @tweeter
						if @band.twitter_user.twitter_id == @tweeter.id
						
							#all good to retweet
							@retweet = @tweet.text
							@endtags = generate_endtag(@tweeter.screen_name, nil)
							@msg = ''
							@ellipsis = '...'
							
							endtaglen = @endtags.length
							tweetlen = @retweet.length
							
							if endtaglen + tweetlen <= TWEET_MAX_LENGTH
								@msg = @retweet + @endtags
							else
								cutlen = TWEET_MAX_LENGTH - endtaglen - @ellipsis.length
								@msg = @retweet[0,cutlen]+@ellipsis+@endtags
							end				
						else
							flash[:error] = 'The band ID and tweeting user didn\'t match up.'			
							redirect_to session[:last_clean_url]
						end
					else
						flash[:error] = 'Couldn\'t find the tweet posting user.'
						redirect_to session[:last_clean_url]
					end		
				else
					flash[:error] = 'Cound\'t get the parameters to post a re-tweet.'
					redirect_to session[:last_clean_url]
				end
			else
					redirect_to :action => 'create_session', :redirect_url => url_for()
			end
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false
		end					
	end
	
	def post_retweet
		begin
			options = {}
			options.update(:in_reply_to_status_id => params[:in_reply_to_status_id]) if params[:in_reply_to_status_id].present?
	
			if params[:twitter_api]
				if params[:twitter_api][:user_id] && params[:twitter_api][:message]
					tweet = client.update(params[:twitter_api][:message])
					flash[:notice] = "Got it! Tweet ##{tweet.id} created."
					redirect_to :action => 'show', :id => tweet.id
				else
					flash[:error] = 'Could not get required parameters to post message.'			
					redirect_to session['last_clean_url']
				end
			else
				flash[:error] = 'Could not get required parameters to post message.'
				redirect_to session['last_clean_url']
			end
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end					
	end
	
  def index
  	begin
			params[:page] ||= 1
			@tweets = client.friends_timeline(:page => params[:page])
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end					
  end

	def band_index
		begin
			params[:page] ||= 1
			@tweets = client(true, false, params[:band_id]).friends_timeline(:page => params[:page])
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end					    
	end

  def show
  	begin
			@tweet = client.status(params[:id])
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end							
  end

  def mentions
		begin		
			params[:page] ||= 1
			@mentions = client.replies(:page => params[:page])
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end								
  end

  def favorites
  	begin
			params[:page] ||= 1
			@favorites = client.favorites(:page => params[:page])
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end								
  end

  def create
  	begin
			options = {}
			options.update(:in_reply_to_status_id => params[:in_reply_to_status_id]) if params[:in_reply_to_status_id].present?
	
			tweet = client.update(params[:twitter_api][:text])
			flash[:notice] = "Got it! Tweet ##{tweet.id} created."
			redirect_to :action => 'show', :id => tweet.id
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end								
  end

  def band_create
  	begin
			options = {}
			options.update(:in_reply_to_status_id => params[:in_reply_to_status_id]) if params[:in_reply_to_status_id].present?
	
			if params[:twitter_api]
				if params[:twitter_api][:band_id] && params[:twitter_api][:text]
					tweet = client(true, true, params[:twitter_api][:band_id]).update(params[:twitter_api][:text])
					flash[:notice] = "Got it! Tweet ##{tweet.id} created."
					redirect_to :action => 'show', :id => tweet.id
				else
					flash[:error] = 'Could not get required parameters to post message.'			
					redirect_to session['last_clean_url']
				end
			else
				flash[:error] = 'Could not get required parameters to post message.'
				redirect_to session['last_clean_url']
			end
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end								
  end


  def fav
  	begin
			flash[:notice] = "Tweet fav'd. May not show up right away due to API latency."
			client.favorite_create(params[:id])
			redirect_to :action => 'show', :id => tweet.id
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end					
			
  end

  def unfav
  	begin
			flash[:notice] = "Tweet unfav'd. May not show up right away due to API latency."
			client.favorite_destroy(params[:id])
			redirect_to :action => 'show', :id => tweet.id
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end								
  end

  
  private
  
  def update_twitter_user_name
  
  end
  
  def generate_endtag(screen_name = nil, url = nil)
		endtag_str = ''
  	if screen_name
			endtag_str +=' @'+screen_name
		end
		if url
			endtag_str += ' '+url
		end
		
		endtag_str += ' #MyBandStock'
  end
  
  
end
