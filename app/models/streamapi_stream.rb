class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :stream, :polymorphic => true
  has_many :streamapi_stream_viewer_statuses
end
