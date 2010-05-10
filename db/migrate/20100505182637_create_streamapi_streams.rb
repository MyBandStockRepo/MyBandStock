class CreateStreamapiStreams < ActiveRecord::Migration
  def self.up
    create_table :streamapi_streams do |t|
      t.string :private_hostid, :null => false
      t.string :public_hostid, :null => false
      t.string :title, :null => false
      t.datetime :start_datetime, :null => false
      t.datetime :end_datetime, :null => false
      t.string :layout_path, :null => false
      t.string :skin_path, :null => false      
      t.boolean :public, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :streamapi_streams
  end
end
