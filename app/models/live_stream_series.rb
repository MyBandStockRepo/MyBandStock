class LiveStreamSeries < ActiveRecord::Base
	has_many :live_stream_series_permissions
	belongs_to :band
	has_and_belongs_to_many :api_user
	has_many :streamapi_streams
	
	
  #	returns nil or users with permissions on stream
	def users_with_permissions()
	  return LiveStreamSeriesPermission.where(:live_stream_series_id => self.id).collect{|p| p.user}
  end
	
	#returns false if it encounters a general error
	#returns true if all emails queued successfully
	#returns an array of failed email addresses if only some emails went out
	
	def send_stream_reminder_email(stream=nil)
    #if stream not specified, find the next one coming up
    if stream == nil
      stream = self.streamapi_streams.where(["starts_at > ?", Time.now]).order("starts_at ASC").first
      if stream.nil?
        return false
      end
    end 
    failed_users = Array.new
    permissions = self.live_stream_series_permissions
    count = 0
    for permission in permissions
      user = permission.user
        
      #make sure thay want email reminders
      if user.receive_email_reminders == true
        if Delayed::Job.enqueue(StreamReminderJob.new(user, stream), 0).nil?
          failed_users << user.email.to_s
        end      
        count += 1
      end
    end
    if failed_users.size() > 0 && failed_users.size() < count
      return failed_users
    elsif failed_users.size() == 0    
      return true
    else
      return false
    end
  end
end
