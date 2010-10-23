class TwitterCrawlerHashTag < ActiveRecord::Base
  belongs_to :band
  has_many :twitter_crawler_trackers
end
