class UserMailer < ActionMailer::Base
  # We will send the following types of emails:
  #   1. New user just bought a product from an external website.
  #     Our API callback receives this notification, along with the email address
  #     and some form of the LiveStreamSeries ID which the user can now access.
  #     This email says "Welcome, you can now view the following live streams.",
  #     Along with an access schedule of each stream in the series.
  #
  #     The email also sends the user's new password which has just been generated,
  #     as well as a link like "You should change your password soon"
  #
  #   2. Existing user just bought a product.
  #     Same email as above, but without "Change password" link.
  #
  #   3. Registration confirmation
  #     User must confirm email address
  #
  #   4. Password change confirmation
  #


  default :from => "noreply@mybandstock.com"  

  def new_user_stream_schedule_notification(user, new_password, band, lss)
    if user.nil?
      return false
    end
    
    recipient = make_address(user)
    
    @user = user
    @password = new_password
    @band = band
    @lss = lss
		@host = SITE_HOST
		@confirmation = SITE_URL+'/users/activate?user_id='+@user.id.to_s+'&code='+@password
    subject = @band.name+' Live Streaming Video'
		mail(:to => recipient, :subject => subject)
  end





  def existing_user_stream_schedule_notification(user, band, lss)
    if user.nil?
      return false
    end

		recipient = make_address(user)

    @user = user    
    @band = band
    @lss = lss  
		@host = SITE_HOST
    
    subject = @band.name+' Live Streaming Video'
		mail(:to => recipient, :subject => subject)    
  end




  def registration_notification(user)
    if user.nil?
      return false
    end

    recipient = make_address(user)

    @user = user  # Send user object to the email view
    @mbslink = SITE_URL
		@host = SITE_HOST
    
    mail(:to => recipient, :subject => "MyBandStock Registration")

    return true
  end  



  
  def confirm_email(email_address, onetime_key)
    @onetime_key = onetime_key
    mail(:to => email_address, :subject => "MyBandStock Email Confirmation")    
  end


	def reset_password(user, password)
  	if user.nil?
      return false
    end

		recipient = make_address(user)
		@user = user
		@password = password
		@host = SITE_HOST
		    @mbslink = SITE_URL
    mail(:to => recipient, :subject => "MyBandStock Password Reset")    		
	end



private

  def make_address(user)
    # Takes a User object, and constructs a string like "Jake Schwartz <jake@mybandstock.com>" if possible
    if user.nil?
      return false
    end

    recipient = '<' + user.email + '>'
    if user.first_name
      recipient = user.full_name + ' ' + recipient
    end
    recipient
  end

end
