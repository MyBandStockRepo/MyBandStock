class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :live_stream_series
  belongs_to :broadcaster_theme, :class_name => 'StreamapiStreamTheme'
  belongs_to :viewer_theme, :class_name => 'StreamapiStreamTheme'

  has_many :streamapi_stream_viewer_statuses
  has_many :recorded_videos
	
  validates_presence_of :title, :starts_at, :ends_at

  
end
