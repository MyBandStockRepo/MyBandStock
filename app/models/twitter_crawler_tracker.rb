class TwitterCrawlerTracker < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :twitter_crawler_hash_tag
#  belongs_to :band, :through => :twitter_crawler_hash_tag
  validates_uniqueness_of :tweet_id, :scope => :twitter_crawler_hash_tag_id
  
  
  
  before_create :tweet_does_not_exist_for_band?
  
  def tweet_does_not_exist_for_band?
    same_tweets = TwitterCrawlerTracker.where(:tweet_id => tweet_id).all
    unless same_tweets.blank?
      for tweet in same_tweets
        if tweet.twitter_crawler_hash_tag.band.id == twitter_crawler_hash_tag.band.id
          #errors.add(:twitter_crawler_hash_tag_id, "This tweet already earned points toward this band.")
          return false
        end
      end
    end
    return true
  end
end
