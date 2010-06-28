class CreateRecordedVideos < ActiveRecord::Migration
  def self.up
    create_table :recorded_videos do |t|
      t.integer :public_hostid, {:null => true, :default => nil} 
      t.string :url, {:null => true, :default => nil} 
      t.boolean :public, {:null => false, :default => false} 
      t.belongs_to :streamapi_stream
      t.timestamps
    end
  end

  def self.down
    drop_table :recorded_videos
  end
end
