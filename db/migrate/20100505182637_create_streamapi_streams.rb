class CreateStreamapiStreams < ActiveRecord::Migration
  def self.up
    create_table :streamapi_streams do |t|
      t.string :private_hostid, :null => false
      t.string :public_hostid, :null => false
      t.string :channel_id, :null => true
      t.string :title, :null => false
      t.datetime :starts_at, :null => false
      t.datetime :ends_at, :null => false
      t.string :layout_path, :null => false
      t.string :skin_path, :null => false      
      t.boolean :public, :null => false
      
      t.integer :duration, :null => true
      t.integer :total_viewers, :null => true
      t.integer :max_concurrent_viewers, :null => true
      t.string :recording_filename, :null => true
      t.string :recording_url, :null => true
      t.string :live_url, :null => true

			t.belongs_to :band, :live_stream_series
      t.timestamps
    end
  end

  def self.down
    drop_table :streamapi_streams
  end
end
