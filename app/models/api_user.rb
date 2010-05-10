class ApiUser < ActiveRecord::Base
	has_many :live_stream_series

  validates_presence_of :api_key, :secret_key
  validates_uniqueness_of :api_key

end
