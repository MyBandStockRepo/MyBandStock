class CreateStreamapiStreams < ActiveRecord::Migration
  def self.up
    create_table :streamapi_streams do |t|
      t.string :private_hostid
      t.string :public_hostid
      t.string :title, :null => false
      t.datetime :starts_at, :null => false
      t.datetime :ends_at, :null => false
      t.string :layout_path, :null => false
      t.string :skin_path, :null => false      
      t.boolean :public, :null => false

			t.belongs_to :band, :live_stream_series

      t.timestamps
    end
  end

  def self.down
    drop_table :streamapi_streams
  end
end
