class StreamapiStream < ActiveRecord::Base
	belongs_to :band
	belongs_to :stream, :polymorphic => true
end
