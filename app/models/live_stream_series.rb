class LiveStreamSeries < ActiveRecord::Base
	has_many :live_stream_permissions
	belongs_to :band
	belongs_to :api_user
end
