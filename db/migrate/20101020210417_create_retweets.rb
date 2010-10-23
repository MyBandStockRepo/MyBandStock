class CreateRetweets < ActiveRecord::Migration
  def self.up
    create_table :retweets do |t|
      t.integer :original_tweet_id
      t.integer :retweet_tweet_id
      t.string :tweet
      t.belongs_to :twitter_user
      t.belongs_to :band
      t.integer :twitter_followers
      t.integer :share_value

      t.timestamps
    end
  end

  def self.down
    drop_table :retweets
  end
end
