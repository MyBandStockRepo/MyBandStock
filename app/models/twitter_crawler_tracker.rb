class TwitterCrawlerTracker < ActiveRecord::Base
  belongs_to :twitter_user
  belongs_to :twitter_crawler_hash_tag
end
