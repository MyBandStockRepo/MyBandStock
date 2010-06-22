class SocialNetworksController < ApplicationController
 before_filter :authenticated?
 before_filter :user_part_of_or_admin_of_a_band?
 
	def index
		begin
			@twitter_not_authorized =  true
			@request_uri = url_for()
			puts 'URL FOR GOT: '+@request_uri
			puts 'REQUEST FULLPATH GOT: '+request.fullpath
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
		rescue
			flash[:error] = 'Sorry, Twitter is being unresponsive at the moment.'
			redirect_to session[:last_clean_url]
			return false			
		end							
	end



end
