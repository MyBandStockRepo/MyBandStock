class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :live_stream_series
end
