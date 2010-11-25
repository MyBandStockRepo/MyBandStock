class SocialNetworksController < ApplicationController
 before_filter :authenticated?
 before_filter :user_part_of_or_admin_of_a_band?
 
	def index
		@twitter_not_authorized =  true
	end



end
