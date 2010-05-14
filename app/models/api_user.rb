class ApiUser < ActiveRecord::Base
	has_and_belongs_to_many :live_stream_series

  validates_presence_of :api_key, :secret_key
  validates_uniqueness_of :api_key

end
