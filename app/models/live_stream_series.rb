class LiveStreamSeries < ActiveRecord::Base
	has_many :live_stream_series_permissions
	belongs_to :band
	has_and_belongs_to_many :api_user
	has_many :streamapi_streams
	
	def send_stream_reminder_email(stream=nil)
    #if stream not specified, find the next one coming up
    if stream == nil
      stream = self.streamapi_streams.where(["starts_at > ?", Time.now]).order("starts_at ASC").first
      if stream.nil?
        return false
      end
      
      logger.info 'SELF TYPE'+self.to_s
      
      permissions = self.live_stream_series_permissions
      #add check here for email opt out
      for permission in permissions
        user = permission.user
        
        #delete old jobs if they exist for this stream already
        
        Delayed::Job.enqueue(StreamReminderJob.new(user, stream), 0, stream.starts_at - 24.hours)
#        oldjoin = stream.delayed_job
      end      
    end
  end
end
