class AddTweetedAtToTwitterCrawlerTrackers < ActiveRecord::Migration
  def self.up
    add_column :twitter_crawler_trackers, :tweeted_at, :datetime
  end

  def self.down
    remove_column :twitter_crawler_trackers, :tweeted_at
  end
end
