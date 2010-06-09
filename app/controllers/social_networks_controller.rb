class SocialNetworksController < ApplicationController
 protect_from_forgery :only => [:update]
 before_filter :authenticated?

	def index
		@twitter_not_authorized =  true

		unless params[:band_short_name]
			flash[:error] = 'Could not find a band name.'
			redirect_to session[:last_clean_url]
			return false
		end

		@band = Band.where(:short_name => params[:band_short_name]).first
		unless @band
			flash[:error] = 'Could not find a band with the given short name.'
			redirect_to session[:last_clean_url]
			return false
		end
				
		unless User.find(session[:user_id]).can_broadcast_for(@band.id)
			flash[:error] = 'You are not a part of this band and don\'t have permission to view this page.'
			redirect_to session[:last_clean_url]
			return false
		end
		
		unless @band.twitter_user
			@twitter_not_authorized = true
		else
			@twit_user = client(true, true, @band.id).verify_credentials
			@twitter_not_authorized = false			
			@tweets = client(true, true, @band.id).user_timeline(:id => @twit_user.id)
		end		


		
		
		
	end



end
