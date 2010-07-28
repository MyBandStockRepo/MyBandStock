# Scheduler which runs contained inside the rails app to fire off stream reminder emails.  Checks every 1 hour

require 'rubygems'
require 'rufus/scheduler'
require 'scheduler_logger.rb'

scheduler = Rufus::Scheduler.start_new


#will run a check every hour and see if any streams within 24 hour window.  
scheduler.every '3m' do

  SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] running script'

  #get all streams with a start time within 24 hours and the stream hasn't had an email go out for it yet
  #since field is datetime, have to do some strange math to get the timezones to match up and to get the date strings in the same format
  #it thinks the start_at field is in the GMT timezone but it isn't actually, so you have to do some offset math
  streamapi_streams = StreamapiStream.where("starts_at > ? AND starts_at < ?", DateTime.now, 1.day.from_now).where(:users_have_been_notified => false, :public => true).all

  #get the lss, send the email, say that users have been notified for each stream
  for stream in streamapi_streams
    lss = stream.live_stream_series
    SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] Found a stream that needs to send out an email STREAM_ID='+stream.id.to_s
    #returns true, false, or an array of failed users if not everyone failed
    #handle y if true or array, say emails sent, otherwise, say they didn't
    email_return_val = lss.send_stream_reminder_email(stream)
    if email_return_val == true
      #worked for everyone
      stream.users_have_been_notified = true
      stream.save()
      SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ==> Mail has been put onto the delayed job queue for all users.'
    elsif email_return_val == false
      #failed for everyone
      #users_have_been_notified already false, don't need to do anything
      SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ==> ERROR: No mail was sent out, either nobody was added to the queue, or there was another error in the method.'      
    else
      #failed for some, worked for some, pretend like it worked for everyone... it's only a reminder, not vital information
      stream.users_have_been_notified = true
      stream.save()
      SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ==> ERROR: Some users were added to the job queue, but not all.'      
    end
  end
  SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] finishing script'
  #Rails.logger.flush  
  
  
end