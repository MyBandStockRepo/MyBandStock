class AddLocationToStreamapiStreams < ActiveRecord::Migration
  def self.up
    add_column :streamapi_streams, :location, :string, :null => true  # Like "Phoenix, AX" or "studio"
  end

  def self.down
    remove_column :streamapi_streams, :location
  end
end
