class StreamapiStreamViewerStatus < ActiveRecord::Base
	belongs_to :streamapi_stream
	belongs_to :user

  validates_presence_of :viewer_key
  validates_presence_of :user_id

  # viewer_keys are unique, as well as (user_id, stramapi_stream_id) pairs
  validates_uniqueness_of :viewer_key
  validates_uniqueness_of :streamapi_stream_id, :scope => :user_id
end
