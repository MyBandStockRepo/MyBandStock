class CreateTwitterCrawlerTrackers < ActiveRecord::Migration
  def self.up
    create_table :twitter_crawler_trackers do |t|
      t.integer :tweet_id
      t.string :tweet
      t.belongs_to :twitter_user
      t.belongs_to :twitter_crawler_hash_tag
      t.integer :twitter_followers
      t.integer :share_value
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_crawler_trackers
  end
end
