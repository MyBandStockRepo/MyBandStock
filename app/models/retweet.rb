class Retweet < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :band
  
  validates_uniqueness_of :original_tweet_id, :scope => :twitter_user_id
end
