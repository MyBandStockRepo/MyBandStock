class TwitterCrawlerTracker < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :twitter_crawler_hash_tag
  
  validates_uniqueness_of :tweet_id, :scope => :twitter_crawler_hash_tag_id
end
