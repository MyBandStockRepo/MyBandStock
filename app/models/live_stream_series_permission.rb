class LiveStreamSeriesPermission < ActiveRecord::Base
	belongs_to :stream, :polymorphic => true
	belongs_to :user
	belongs_to :live_stream_series
end
