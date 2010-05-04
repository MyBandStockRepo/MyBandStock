class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	has_many :live_stream_series_permissions, :as => :stream
end
