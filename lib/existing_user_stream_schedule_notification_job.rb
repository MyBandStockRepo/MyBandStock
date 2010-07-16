class ExistingUserStreamScheduleNotificationJob < Struct.new(:user, :band, :lss)
  def perform
    UserMailer.existing_user_stream_schedule_notification(user, band, lss).deliver
  end  
end
