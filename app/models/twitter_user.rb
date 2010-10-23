class TwitterUser < ActiveRecord::Base
  has_many :twitter_crawler_trackers
  has_many :retweets
  has_many :users
end
