class ApiUser < ActiveRecord::Base
	has_many :live_stream_series

end
