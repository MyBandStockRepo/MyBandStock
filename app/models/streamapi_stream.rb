class StreamapiStream < ActiveRecord::Base
  before_save :check_start_date_change # sees if when someone saves if the start date was modified, and may have to potentially send out new reminder email

	belongs_to :band
	belongs_to :live_stream_series
  belongs_to :broadcaster_theme, :class_name => 'StreamapiStreamTheme'
  belongs_to :viewer_theme, :class_name => 'StreamapiStreamTheme'

  has_many :streamapi_stream_viewer_statuses
  has_many :recorded_videos
	
  validates_presence_of :title, :starts_at, :ends_at

  
  private
  def check_start_date_change
  
   
    if self.id
      #look up old date
      orig_stream = StreamapiStream.find(self.id)
      #compare to new date
      if orig_stream.starts_at != self.starts_at
        #the starts at time changed, let the email get resent whenever it falls into the 24 hour beforehand window
        self.users_have_been_notified = false       
      end        
    end
    return true
  end
    
end
