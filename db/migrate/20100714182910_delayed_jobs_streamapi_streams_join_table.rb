class DelayedJobsStreamapiStreamsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs_streamapi_streams, :id => false do |t|
      t.timestamps
      #references
      t.belongs_to :delayed_job, :streamapi_stream
    end
    add_index(:delayed_jobs_streamapi_streams, [:delayed_job_id, :streamapi_stream_id], :name => 'delayed_jobs_streamapi_streams_join_index')
		
  end

  def self.down
    drop_table :delayed_jobs_streamapi_streams
  end
end
