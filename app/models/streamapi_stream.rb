class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :live_stream_series
  has_many :streamapi_stream_viewer_statuses
  has_one :broadcaster_theme, :class_name => :streamapi_stream_theme
  has_one :viewer_theme, :class_name => :streamapi_stream_theme  
end
