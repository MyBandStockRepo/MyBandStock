class TwitterApiController < ApplicationController
  before_filter :authenticated?, :except => [:error] # Authentication in retweet is done manually
  
  skip_filter :update_last_location  #NOT WORKING FOR SOME REASON  

  #get params for tweet_id and band_id
  def actual_retweet
    #see if user is authenticated with twitter
    @user = User.find(session[:user_id])    
    unless @user.authenticated_with_twitter?
      flash[:error] = "You must first connect your account to Twitter in the \"Connected Social Networks\" section below in order to retweet."
      redirect_to edit_user_path(session[:user_id])
      return false
    end
    
    
    if params[:band_id].blank?
      flash[:error] = "No band specified."
      redirect_to session[:last_clean_url]
      return false
    end
    @band = Band.find(params[:band_id])
    
    if @band && !@band.twitter_username.blank?    
      #see if a status id is specified, if not, use the latest
      if params[:tweet_id].blank?
        #get latest tweet
        begin
          tweet = Twitter.user_timeline(@band.twitter_username, :count => 1).first
        rescue
          flash[:error] = "Could not find the tweet to retweet."
          redirect_to session[:last_clean_url]
          return false
        end
      else
        #get the specified tweet
        begin
          tweet = Twitter.status(params[:tweet_id])
        rescue
          flash[:error] = "Could not find the tweet to retweet."
          redirect_to session[:last_clean_url]
          return false 
        end
      end
      
      unless tweet
        flash[:error] = "Could not find a status to retweet."
        redirect_to session[:last_clean_url]
        return false         
      end
      
      #see which user posted the original message      
      posting_user_id = tweet.user.id
      band_verifier_id = @band.twitter_credentials.id

      #make sure that it came from a band
      if posting_user_id != band_verifier_id
        flash[:error] = "You can only retweet tweets from the band."
        redirect_to session[:last_clean_url]
        return false
      end
      

      #make sure that they haven't already retweeted this
      if Retweet.where(:original_tweet_id => tweet.id, :twitter_user_id => @user.twitter_user.id).count == 0

        #retweet it
        begin
          retweet = @user.twitter_client.retweet(tweet.id)
          flash[:notice] = "Successfully retweeted from #{retweet.user.screen_name}"
        rescue
          flash[:error] = "There was an error while trying to retweet."
          redirect_to session[:last_clean_url]
          return false
        end

        followers = @user.twitter_user.followers
        shares = twitter_follower_point_calculation(followers)

        available_shares = @band.available_shares_for_earning
        if available_shares && available_shares < shares
          shares = available_shares
        end
                
        #award bandstock
        Retweet.create(:original_tweet_id => tweet.id, :retweet_tweet_id => retweet.id.to_s, :tweet => retweet.text, :twitter_user_id => @user.twitter_user.id, :band_id => @band.id, :twitter_followers => followers, :share_value => shares)
        ShareLedgerEntry.create( :user_id => session[:user_id],
                                        :band_id => @band.id,
                                        :adjustment => shares,
                                        :description => 'retweet_band'
                            )
      else
        flash[:error] = 'You have already retweeted this status and can only retweet each status once.'
        redirect_to session[:last_clean_url]
  		  return false
      end
    else
      flash[:error] = "No twitter account specified for band."
      redirect_to session[:last_clean_url]
      return false      
    end
    if request.xhr?
		  render :layout => false
		end
    redirect_to :controller => "bands", :action => "show", :id => @band.id
  end


	
	def error
		@showerror	= false
		unless params[:lightbox].nil?
			@showerror = true
      # If our request tells us not to display layout (in a lightbox, for instance)
      render :layout => 'lightbox'
      return
    end
    
		if request.xhr? || params[:lightbox]
			render :layout => false
		end    
	end
	
  private
    
  
  def generate_endtag(screen_name = nil, long_url = nil)
		endtag_str = ''
#  	if screen_name
#			endtag_str +=' @'+screen_name
#		end
		if long_url
		  short_url = ShortUrl.generate_short_url(long_url)
			endtag_str += ' '+short_url
		end
  end

end

