class UserMailer < ActionMailer::Base
  default :from => "noreply@mybandstock.com"  
     
  def registration_notification(user)  
    mail(:to => user.primary_email, :subject => "MyBandStock Registration")  
  end  
  
  def confirm_email(email_address, onetime_key)
    mail(:to => email_address, :subject => "MyBandStock email confirmation")
    @onetime_key = onetime_key
  end
end
