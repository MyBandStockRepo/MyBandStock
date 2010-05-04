class CreateStreamapiStreamPermissions < ActiveRecord::Migration
  def self.up
    create_table :streamapi_stream_permissions do |t|
      t.boolean :can_view
      t.boolean :can_chat
      t.string :stream_quality_level

      t.timestamps
    end
  end

  def self.down
    drop_table :streamapi_stream_permissions
  end
end
