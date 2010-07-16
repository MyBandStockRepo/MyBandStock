class StreamReminderJob < Struct.new(:user, :stream)
  def perform
    UserMailer.stream_reminder(user, stream).deliver
  end  
end
