class ChangeTwitterIdInRetweetToString < ActiveRecord::Migration
  def self.up
    change_column(:retweets, :original_tweet_id, :string)        
    change_column(:retweets, :retweet_tweet_id, :string)            
  end

  def self.down
  end
end
