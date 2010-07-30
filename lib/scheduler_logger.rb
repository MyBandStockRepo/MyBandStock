class SchedulerLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n" 
  end 
end

#do logging in a seperate file
logfile = File.open(Rails.root.to_s+'/log/scheduler.log', 'a')    
logfile.sync = true
SCHEDULER_LOG = SchedulerLogger.new(logfile)
