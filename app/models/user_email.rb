class UserEmail < ActiveRecord::Base
	belongs_to :user
	
	before_create :send_confirmation_email
	
	
	
	def send_confirmation_email
	  UserMailer.registration_confirmation(@user).deliver(self.address, self.onetime_key)
  end
end
