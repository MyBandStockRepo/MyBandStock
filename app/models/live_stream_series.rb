class LiveStreamSeries < ActiveRecord::Base
	has_many :live_stream_permissions
	belongs_to :band
	has_and_belongs_to_many :api_user
	has_many :streamapi_streams
end
