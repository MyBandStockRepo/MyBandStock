class NewUserStreamScheduleNotificationJob < Struct.new(:user, :new_password, :band, :lss)
  def perform
    UserMailer.new_user_stream_schedule_notification(user, new_password, band, lss).deliver
  end  
end
