class StreamapiStreamViewerStatuses < ActiveRecord::Migration
  def self.up
    create_table :streamapi_stream_viewer_statuses do |t|
      t.string :ip_address, :null => true
      t.string :viewer_key, :null => false
			t.belongs_to :streamapi_stream, :user
	
      t.timestamps
    end
    add_index :streamapi_stream_viewer_statuses, :viewer_key, { :unique => true }
  end

  def self.down
    drop_table :streamapi_stream_viewer_statuses
  end
end
