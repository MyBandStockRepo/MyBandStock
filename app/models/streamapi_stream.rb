class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :live_stream_series
    has_many :streamapi_stream_viewer_statuses
end
