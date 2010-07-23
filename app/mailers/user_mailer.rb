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
		@host = SITE_HOST || 'mybandstock.com'
		site_url = SITE_URL || 'http://mybandstock.com'
		@confirmation = site_url+'/users/activate?user_id='+@user.id.to_s+'&code='+@password
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
		@host = (defined? SITE_HOST ) ? SITE_HOST : 'mybandstock.com'
    
    subject = @band.name+' Live Streaming Video'
		mail(:to => recipient, :subject => subject)    
  end




  def registration_notification(user)
    if user.nil?
      return false
    end

    recipient = make_address(user)

    @user = user  # Send user object to the email view
    @mbslink = (defined? SITE_URL ) ? SITE_URL : 'http://mybandstock.com'
		@host = (defined? SITE_HOST ) ? SITE_HOST : 'mybandstock.com'
    
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
		@host = SITE_HOST || 'mybandstock.com'
		    @mbslink = SITE_URL || 'http://mybandstock.com'
    mail(:to => recipient, :subject => "MyBandStock Password Reset")    		
	end

	def stream_reminder(user, stream)
  	if user.nil? || stream.nil?
      return false
    end

		recipient = make_address(user)
		@user = user
    @band = stream.band
    @lss = stream.live_stream_series
    @stream = stream
		@host = SITE_HOST || 'mybandstock.com'
    @mbslink = SITE_URL || 'http://mybandstock.com'
    
    subject = "Reminder - live stream for "+@band.name+" coming up"
    mail(:to => recipient, :subject => subject)    		
	end

	def send_announcement(users, subject, message)
  	if users.nil? || subject.nil? || message.nil?
      return false
    end
    
		rec_arr = users.collect{|u| make_address(u)}
		logger.info rec_arr
		@host = SITE_HOST || 'mybandstock.com'
    @mbslink = SITE_URL || 'http://mybandstock.com'
    @message = message
    mail(:to => rec_arr, :subject => subject)    		
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
