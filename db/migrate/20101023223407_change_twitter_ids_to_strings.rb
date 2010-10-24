class ChangeTwitterIdsToStrings < ActiveRecord::Migration
  def self.up
    change_column(:twitter_crawler_hash_tags, :last_tweet_id, :string)
    change_column(:twitter_crawler_trackers, :tweet_id, :string)    
  end

  def self.down
  end
end
