class RegistrationNotificationJob < Struct.new(:user)
  def perform
    UserMailer.registration_notification(user).deliver
  end  
end
