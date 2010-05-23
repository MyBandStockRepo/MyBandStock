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

  def new_user_stream_schedule_notification(user, new_password)
    if user.nil?
      return false
    end
    
  end

  def existing_user_stream_schedule_notification(user)
    if user.nil?
      return false
    end
  end

  def registration_notification(user)
    if user.nil?
      return false
    end

    recipient = make_address(user)

    @user = user  # Send user object to the email view
    mail(:to => recipient, :subject => "MyBandStock Registration")

    return true
  end  
  
  def confirm_email(email_address, onetime_key)
    mail(:to => email_address, :subject => "MyBandStock email confirmation")
    @onetime_key = onetime_key
  end


private

  def make_address(user)
    # Takes a User object, and constructs a string like "Jake Schwartz <jake@mybandstock.com>" if possible
    if user.nil?
      return false
    end

    recipient = '<' + user.email + '>'
    if user.first_name
      recipient = user.first_name + ' ' + user.last_name + ' ' + recipient
    end
    recipient
  end

end
