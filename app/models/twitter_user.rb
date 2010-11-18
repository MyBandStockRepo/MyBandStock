class TwitterUser < ActiveRecord::Base
  belongs_to :authentication
  has_many :twitter_crawler_trackers
  has_many :retweets
  has_many :users
  validates_presence_of :twitter_id
  validates_uniqueness_of :twitter_id
end
