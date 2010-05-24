class CreateLiveStreamSeriesPermissions < ActiveRecord::Migration
  def self.up
    create_table :live_stream_series_permissions do |t|
      t.boolean :can_view, :null => false
      t.boolean :can_listen, :null => false, :default => false
      t.boolean :can_chat, :null => false, :default => false
      t.string :stream_quality_level, :null => true
			t.belongs_to :user, :live_stream_series
	
      t.timestamps
    end
  end

  def self.down
    drop_table :live_stream_series_permissions
  end
end
