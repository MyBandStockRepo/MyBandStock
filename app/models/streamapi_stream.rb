class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :live_stream_series
  has_many :streamapi_stream_viewer_statuses
  belongs_to :broadcaster_theme, :class_name => 'StreamapiStreamTheme'
  belongs_to :viewer_theme, :class_name => 'StreamapiStreamTheme'
end
