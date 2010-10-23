class AddSharesAwardedToTwitterCrawlerTracker < ActiveRecord::Migration
  def self.up
    add_column :twitter_crawler_trackers, :shares_awarded, :boolean, :default => false
  end

  def self.down
    remove_column :twitter_crawler_trackers, :shares_awarded
  end
end
