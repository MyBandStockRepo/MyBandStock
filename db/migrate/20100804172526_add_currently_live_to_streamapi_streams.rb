class AddCurrentlyLiveToStreamapiStreams < ActiveRecord::Migration
  def self.up
    add_column :streamapi_streams, :currently_live, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :streamapi_streams, :currently_live
  end
end
