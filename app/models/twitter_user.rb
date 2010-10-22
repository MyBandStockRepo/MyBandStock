class TwitterUser < ActiveRecord::Base
  has_many :twitter_crawler_trackers
  has_many :retweets
end
