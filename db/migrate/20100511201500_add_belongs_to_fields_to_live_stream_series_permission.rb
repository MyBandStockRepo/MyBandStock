class AddBelongsToFieldsToLiveStreamSeriesPermission < ActiveRecord::Migration
  def self.up
    add_column :live_stream_series_permissions, :user_id, :integer,  {:null => false, :default => 0}
    add_column :live_stream_series_permissions, :live_stream_series_id, :integer,  {:null => false, :default => 0}
  end

  def self.down
    remove_column :live_stream_series_permissions, :live_stream_series_id
    remove_column :live_stream_series_permissions, :user_id
  end
end
