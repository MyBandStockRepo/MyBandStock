class TwitterUser < ActiveRecord::Base
  belongs_to :authentication
  has_many :twitter_crawler_trackers
  has_many :retweets
  has_many :users, :through => :authentication
  validates_presence_of :twitter_id
  validates_uniqueness_of :twitter_id  
    
  def client
    if self.authenticated?
      #new with twitter gem 1.0              
      begin
        return Twitter::Client.new(:oauth_token => self.oauth_access_token, :oauth_token_secret => self.oauth_access_secret)          
      rescue
        return nil
      end
    end
    return nil
  end
  
  def authenticated?
    if self.oauth_access_token && self.oauth_access_secret
      return true
    end
    return false
  end

  def followers
    twitter_client = self.client
    if twitter_client
      begin
        return twitter_client.verify_credentials.followers_count
      rescue
        return 0
      end
    else
      return 0
    end
  end

end
