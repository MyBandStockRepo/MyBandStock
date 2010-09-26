class AddPublicToLiveStreamSeries < ActiveRecord::Migration
  def self.up
    add_column :live_stream_series, :public, :boolean, :default => true
  end

  def self.down
    remove_column :live_stream_series, :public
  end
end
