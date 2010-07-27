class AddUsersHaveBeenNotifiedFieldToStreamapiStreams < ActiveRecord::Migration
  def self.up
    add_column :streamapi_streams, :users_have_been_notified, :boolean, {:null => false, :default => false}
  end

  def self.down
    remove_column :streamapi_streams, :users_have_been_notified
  end
end
