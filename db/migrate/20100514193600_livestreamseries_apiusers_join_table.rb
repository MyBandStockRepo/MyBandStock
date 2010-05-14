class LivestreamseriesApiusersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :api_users_live_stream_series, :id => false do |t|
      t.timestamps
      #references
      t.belongs_to :api_user, :live_stream_series
    end

  end

  def self.down
    drop_table :api_users_live_stream_series
  end
end
