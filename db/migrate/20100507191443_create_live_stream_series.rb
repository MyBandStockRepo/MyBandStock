class CreateLiveStreamSeries < ActiveRecord::Migration
  def self.up
    create_table :live_stream_series do |t|
      t.string :title, :null => false
      t.datetime :start_datetime, :null => false
      t.datetime :end_datetime, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :live_stream_series
  end
end
