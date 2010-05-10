class StreamapiStreamPermission < ActiveRecord::Base
	belongs_to :streamapi_stream
	belongs_to :user
end
