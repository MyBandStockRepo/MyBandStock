class SchedulerLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n" 
  end 
end

current_directory = File.expand_path(File.dirname(__FILE__))
#do logging in a seperate file
logfile = File.open(current_directory+'/../log/scheduler.log', 'a')    
logfile.sync = true
SCHEDULER_LOG = SchedulerLogger.new(logfile)
