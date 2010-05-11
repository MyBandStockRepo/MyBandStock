class AddBelongsToFieldsToStreamapiStream < ActiveRecord::Migration
  def self.up
    add_column :streamapi_streams, :band_id, :integer, {:null => false, :default => 0}
    add_column :streamapi_streams, :live_stream_series_id, :integer,  {:null => false, :default => 0}
  end

  def self.down
    remove_column :streamapi_streams, :live_stream_series_id
    remove_column :streamapi_streams, :band_id
  end
end
