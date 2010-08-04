#!/usr/bin/ruby
#Script run by a cron job to check if emails need to go out and to send them out
#set RAILS_ENV here since it doesn't run rails
RAILS_ENV='development'



if RAILS_ENV=='development'
  SITE_URL = 'http://127.0.0.1:3000'
  SECURE_SITE_URL = 'http://127.0.0.1:3000'
  SITE_HOST = '127.0.0.1:3000'
elsif RAILS_ENV=='production'
  SITE_URL = 'http://mybandstock.com'
  SECURE_SITE_URL = 'https://mybandstock.com'
  SITE_HOST = 'mybandstock.com'
elsif RAILS_ENV=='staging'
  SITE_URL = 'http://gary.mybandstock.com'
  SECURE_SITE_URL = 'http://gary.mybandstock.com'
  SITE_HOST = 'gary.mybandstock.com'
end
MBS_SUPPORT_EMAIL = 'help@mybandstock.com'

#get the current directory (the lib folder path)
current_directory = File.expand_path(File.dirname(__FILE__))

#Necessary requires since rails isn't running
require 'rubygems'
require 'active_record'
require 'action_mailer'
require 'yaml'
require 'logger'
include ActionView::Helpers::UrlHelper
include ActionView::Helpers::TagHelper

#scheduler log file
require current_directory+'/scheduler_logger.rb'

#connect activerecord to DB
dbconfig = YAML::load(File.open(current_directory+'/../config/database.yml'))[RAILS_ENV]
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.establish_connection(dbconfig)

#connect actionmailer
ActionMailer::Base.smtp_settings = {
  :address              => "email.mybandstock.com",
  :port                 => 587,
  :domain               => "mybandstock.com",
  :user_name            => "mybandstock",
  :password             => "myb4ndst0ck",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

#models
require current_directory+'/../app/models/user.rb'
require current_directory+'/../app/models/band.rb'
require current_directory+'/../app/models/live_stream_series.rb'
require current_directory+'/../app/models/live_stream_series_permission.rb'
require current_directory+'/../app/models/streamapi_stream.rb'

#mailer
require current_directory+'/../app/mailers/user_mailer.rb'

SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] running cron script'

begin
  #get all streams with a start time within 24 hours and the stream hasn't had an email go out for it yet
  #since field is datetime, have to do some strange math to get the timezones to match up and to get the date strings in the same format
  #it thinks the start_at field is in the GMT timezone but it isn't actually, so you have to do some offset math
  #streamapi_streams = StreamapiStream.where("starts_at > ? AND starts_at < ?", Time.now.utc.to_datetime, 1.day.from_now.utc.to_datetime).where(:users_have_been_notified => false, :public => true).all

  streamapi_streams = StreamapiStream.where("starts_at > ? AND starts_at < ?", Time.now.utc.to_datetime, 1.day.from_now.utc.to_datetime).where(:users_have_been_notified => false, :public => true).all

  #get the lss, send the email, say that users have been notified for each stream
  for stream in streamapi_streams
    lss = stream.live_stream_series
    SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] Found a stream that needs to send out an email STREAM_ID='+stream.id.to_s  
  
    permissions = lss.live_stream_series_permissions
    unless permissions.nil?
      for permission in permissions
        user = permission.user
        
        #make sure thay want email reminders
        if user.receive_email_reminders == true
          #send mail
          UserMailer.stream_reminder(user, stream).deliver
          SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ==> Mail has been delivered to '+user.email.to_s
      
        end
      end
      SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ====> All Mail has been delivered.'
      stream.users_have_been_notified = true
      stream.save()
    else
      SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+']  ====> No users have permissions on this stream.'
    end
  end

  SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] finishing cron script'
rescue
  SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] ERROR, RAN INTO EXCEPTION:'
  SCHEDULER_LOG.info $!.to_s+' , LINE: '+$@.to_s
  
end



# OLD RUFUS SCHED STUFF

# Scheduler which runs contained inside the rails app to fire off stream reminder emails.  Checks every 30mins
=begin
  require 'rubygems'
  require 'rufus/scheduler'
  require 'scheduler_logger.rb'

  scheduler = Rufus::Scheduler.start_new

  SCHEDULER_LOG.info '[SCHEDULER]['+DateTime.now.to_s+'] scheduler included from rails app with ruby PID='+Process.pid.to_s


  #will run a check every 30 mins and see if any streams within 24 hour window.  
  scheduler.every '30m' do

    SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] running script ruby PID='+Process.pid.to_s

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
  
    SCHEDULER_LOG.info '[AUTO_EMAIL_SCHEDULER]['+DateTime.now.to_s+'] finishing script ruby PID='+Process.pid.to_s
  end
=end