class AddHasGuestCamToStreamapiStreamThemes < ActiveRecord::Migration
  def self.up
    add_column :streamapi_stream_themes, :has_guest_cam, :boolean, :default => false
  end

  def self.down
    remove_column :streamapi_stream_themes, :has_guest_cam
  end
end
