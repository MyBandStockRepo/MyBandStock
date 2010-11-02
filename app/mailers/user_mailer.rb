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
    @profilelink = (defined? SITE_URL) ? SITE_URL+'/users/'+@user.id.to_s : 'http://mybandstock.com/users/'+@user.id.to_s
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

	def stream_reminder(user_param, stream_param)
  	if user_param.nil? || stream_param.nil?
      return false
    end

		recipient = make_address(user_param)
		@user = user_param
    @band = stream_param.band
    @lss = stream_param.live_stream_series
    @stream = stream_param
		@host = SITE_HOST || 'mybandstock.com'
    @mbslink = SITE_URL || 'http://mybandstock.com'
    @support_email = MBS_SUPPORT_EMAIL || 'help@mybandstock.com'
    
    subject = "Reminder - live stream for "+@band.name+" coming up"

    #convert times to UTC
    offset = Time.now.utc_offset
    stream_starts_at = @stream.starts_at
    stream_starts_at = stream_starts_at.utc + offset

    
    #convert times to ET
    stream_starts_at = stream_starts_at.in_time_zone('Eastern Time (US & Canada)')
    
    
    mail(:to => recipient, :subject => subject) do |format|
      format.html{ render 'app/views/user_mailer/reminder.html.erb', :locals => {:stream_starts_at => stream_starts_at} }    
    end
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
    
    #do this because the interceptor doesn't work on bcc addresses
    if RAILS_ENV == "development"
      mail(:to => rec_arr, :subject => subject)    		
    else
      mail(:bcc => rec_arr, :subject => subject)    		      
    end
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
