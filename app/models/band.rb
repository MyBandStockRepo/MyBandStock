require 'net/http'
require "rexml/document"
require 'digest/md5'
include REXML

class Band < ActiveRecord::Base
  
  has_many :associations, :dependent => :destroy
  has_many :users, :through => :associations

  has_many :members, :through => :associations, :source => :user, :conditions => "associations.name = 'member'"
  has_many :admins, :through => :associations, :source => :user, :conditions => "associations.name = 'admin'"

  # A shortened URL might have a "maker", which could refer to a band or a user.
  has_many :short_urls, :as => :maker
  has_many :share_totals
  belongs_to :country
  belongs_to :state
  belongs_to :twitter_user
  has_many :live_stream_series, :dependent => :destroy
  has_many :streamapi_streams, :through => :live_stream_series
  has_many :recorded_videos, :through => :streamapi_streams
  has_many :pledges
  has_many :share_code_groups
  has_many :twitter_crawler_hash_tags
  has_many :twitter_crawler_trackers, :through => :twitter_crawler_hash_tags
  has_many :retweets
  has_many :promotional_codes
  
#  has_many :contributions, :dependent => :destroy
#  has_many :contributors, :through => :contributions, :source => :user, :uniq => true

#  has_many :stage_comments, :dependent => :destroy
#  has_many :photos, :dependent => :destroy

#  has_many :band_mails
  #has_many :received_mail, :through => 'band_mail', :source => 'BandMail', :conditions => 'from_band = 0'
  
  validates_presence_of :name, :country_id, :zipcode, :city, :short_name, :secret_token
#  validates_acceptance_of :terms_of_service, :accept => true, :message => "You must agree to our terms of service."
  validates_numericality_of :zipcode, :country_id
  validates_numericality_of :purchaseable_shares_release_amount, :unless => Proc.new {|band| band.purchaseable_shares_release_amount.nil? || band.purchaseable_shares_release_amount == ''}
  validates_numericality_of :earnable_shares_release_amount, :unless => Proc.new {|band| band.earnable_shares_release_amount.nil? || band.earnable_shares_release_amount == ''}
  validates_numericality_of :min_share_purchase_amount, :unless => Proc.new {|band| band.min_share_purchase_amount.nil? || band.min_share_purchase_amount == ''}
  validates_numericality_of :max_share_purchase_amount, :unless => Proc.new {|band| band.max_share_purchase_amount.nil? || band.max_share_purchase_amount == ''}
  validates_numericality_of :share_price, :unless => Proc.new {|band| band.share_price.nil? || band.share_price == ''}
  
  validates_uniqueness_of :short_name
  validates_length_of     :short_name, :in => 3..15
  validates_exclusion_of  :short_name, :in => %w[
      admin application bands charts concerts contests contribution_levels
      earned_perks ledger_entries legal login merchant music_albums news_entries
      perks photo_albums photos projects search songs stage_comments users support],
    :message => 'Sorry, but that shortname conflicts with a list of words reserved by the website.'
  validates_format_of     :short_name, :with => /^[\w]{3,15}$/, :message => "Must have only letters, numbers, and _."
  
  before_validation(:on => :create) do generate_secret_token() end


  validate :valid_purchasing_options?


  #makes sure that if purchasing is turned on, the share price and minimum amounts to buy are set
  def valid_purchasing_options?
    #Validate numericallity of purchaseable_shares_release_amount, earnable_shares_release_amount, share_price, min share purcahse amount, max share purchase amount
    if self.commerce_allowed && self.min_share_purchase_amount.blank?
      errors.add(:min_share_purchase_amount, "Must be set if allowing commerce")      
    end 
    if self.min_share_purchase_amount &&  self.min_share_purchase_amount < 1
      errors.add(:min_share_purchase_amount, "Has to be greater than 0")      
    end
    
    if self.commerce_allowed && self.max_share_purchase_amount.blank?
      errors.add(:max_share_purchase_amount, "Must be set if allowing commerce")      
    end
    if self.max_share_purchase_amount && self.max_share_purchase_amount > 100000
      errors.add(:max_share_purchase_amount, "Has to be less than or equal to 100,000")      
    end    
    if self.max_share_purchase_amount && self.min_share_purchase_amount && self.max_share_purchase_amount < self.min_share_purchase_amount
      errors.add(:max_share_purchase_amount, "Has to be greater than the minimum")      
    end
    
    if self.commerce_allowed && self.share_price.blank?
      errors.add(:share_price, "Must be set if allowing commerce")      
    end     
    if self.share_price && self.share_price < 0.01
      errors.add(:share_price, "Has to be greater than 0.01")      
    end

  end

  def convert_to_eastern_time(time)
	  return time.utc.in_time_zone('Eastern Time (US & Canada)')
  end
  
  def status_feed(num_items = 7, text_length_limit = 200)
  # This function returns an array of recent social statuses for the band instance.
  # On failure or no statuses, nil is returned.
  # Currently, the only source queried is Twitter, but this method will be a central point for all social feeds.
  #
  # TODO: Set a timeout on the HTTP requests, and return a special value on timeout. Then the view will tell javascript to
  #   make the request client-side.
  #
    twitter_username = (self.twitter_user) ? self.twitter_user.user_name : self.twitter_username
    return nil if twitter_username.blank?
    twitter_timeline_uri = URI.parse('http://twitter.com/statuses/user_timeline.xml?screen_name=' + twitter_username)
    http = Net::HTTP.new(twitter_timeline_uri.host, twitter_timeline_uri.port)
    request = Net::HTTP::Get.new(twitter_timeline_uri.request_uri)

    response = http.request(request)
    logger.info "Status feed: Twitter response code [#{response.code}]"
    return nil if response.code != '200'
    
    xml_doc = Document.new(response.body)
    
    statuses = Array.new
    # Loop through each XML element, adding them to the statuses array
    xml_doc.root.each_element_with_text{ |status|      
       # Truncate text to the specified limit
      body =  if text_length_limit
                status.elements['text'].text[0..text_length_limit] + '...'
              else
                status.elements['text'].text
              end
      status_id = status.elements['id'].text
      profile_image_url = status.elements['user'].elements['profile_image_url'].text
       # We make a hash of band ID + status ID + band secret token.
       # This is then used to make sure the user doesn't try tweeting somebody else other than the band.
      hash_identifier = Digest::MD5.hexdigest(self.id.to_s + status_id.to_s + self.secret_token.to_s)
      statuses << {
                    :source =>  'Twitter',
                    :status_id => status_id,
                    :body =>  body,
                    :username =>  twitter_username,
                    :posted_at => status.elements['created_at'].text,
                    :hash_identifier => hash_identifier,
                    :profile_image_url => profile_image_url
                  }
      

    }
    statuses[0..(num_items-1)]  # Return truncated array
  end
  

  # returns the next public streamapi stream out of all their series and if none exist, returns nil
  def next_stream
    return self.streamapi_streams.where('streamapi_streams.starts_at > ? AND streamapi_streams.public = ?', Time.now, true).order('streamapi_streams.starts_at ASC').first
  end
    
  #returns an array of streams the band is currently broadcasting on, or nil
  def current_broadcast_streams
    return self.streamapi_streams.where(:currently_live => true).all
  end
    
  def available_shares_for_purchase
  # Returns the number of shares available for purchase for the band, for this time period.
  # Shares are only limited in the contexts of direct purchases. That is, someone can always retweet for shares,
  #   but direct dollar-for-share purchases are limited.
  # Dependents:
  #   NUM_SHARES_PER_BAND_PER_DAY - in environment.rb, setting the limit for the amount of available shares/band/day
  # Every [SHARE_LIMIT_LIFETIME], [NUM_SHARES_PER_BAND_PER_DAY] become available for the band, beginning at the most recent noon.
  # There are no "rollover" shares, which means that N_S_P_B_P_D is the maximum amount of shares available in that
  #   band per day.
  #
    
    dispersed_shares_sum    = 0          # This will be the total number of dispersed shares within the past SHARE_LIMIT_LIFETIME
    noon_today        = (Time.zone.now.midnight + 12.hours)   # Noon today in Eastern Time (like 'Mon Aug 02 12:00:00 EDT 2010')
    
    if noon_today > Time.zone.now
      most_recent_noon = noon_today - 1.day
    else
      most_recent_noon = noon_today
    end
    
    dispersed_shares =  ShareLedgerEntry.where(
                                           :band_id     => self.id,
                                           :description => 'direct_purchase'
                                         ).where(
                                           ["created_at > ?", most_recent_noon.utc]
                                         ).all

    dispersed_shares.each{ |entry|
      dispersed_shares_sum += entry.adjustment  # Takes works with negative adjustments
    }
    
    #if there is no cap on released share amounts, set it to the max per transaction amount
    if self.purchaseable_shares_release_amount.blank?
      available_shares = self.max_share_purchase_amount
    else
      available_shares = self.purchaseable_shares_release_amount - dispersed_shares_sum
      available_shares = (available_shares >= 0) ? available_shares : 0      
    end
    
    return available_shares.to_i
  end
  
  def available_shares_for_earning
    #returns nil if no cap on the shares or the number of avaialable shares, it will never return a negative number
    

    retweet_shares_sum    = 0
    hash_tag_shares_sum   = 0
    noon_today        = (convert_to_eastern_time(Time.now.utc).midnight + 12.hours)   # Noon today in Eastern Time (like 'Mon Aug 02 12:00:00 EDT 2010')
    
    if noon_today > convert_to_eastern_time(Time.now.utc)
      most_recent_noon = noon_today - 1.day
    else
      most_recent_noon = noon_today
    end
    
    #get all the retweets
    retweet_shares =  self.retweets.where(["created_at > ?", most_recent_noon.utc]).all
    retweet_shares.each{ |entry|
      retweet_shares_sum += entry.share_value
    }
    puts 'RETWEET SHARES IN LAST DAY: '+retweet_shares_sum.to_s
    
    
    #get all the hash tags and phrases
    hash_tag_shares =  self.twitter_crawler_trackers.where(["twitter_crawler_trackers.created_at > ?", most_recent_noon.utc]).all
    hash_tag_shares.each{ |entry|
      hash_tag_shares_sum += entry.share_value
    }
    puts 'HASH TAG SHARES IN LAST DAY: '+hash_tag_shares_sum.to_s
    
    
    #if there is no cap on released share amounts, set it to nil
    if self.earnable_shares_release_amount.blank?
      available_shares = nil
    else
      available_shares = self.earnable_shares_release_amount - retweet_shares_sum - hash_tag_shares_sum
      available_shares = (available_shares >= 0) ? available_shares : 0      
    end
    puts 'AVAILABLE SHARES: '+available_shares.to_s
    return available_shares
  end  
  
  
=begin
  def share_price()
  # This method returns the price per share for the given band.
  # Currently, the share price is simply a static constant, defined in environment.rb.
  #
    return Cobain::Application::MBS_SHARE_PRICE
  end
=end

  def self.search_by_name(name)
  # Returns a band, given some common variation of its name or short name.
  #
    return nil if name.nil? || name == ''

    # Let's pretend name = 'Daft Punk'. Search matches one of:
    # 'Daft Punk'
    # 'daftpunk'
    # 'daft_punk'
    # 'DAFTPUNK'
    # 'daft punk'
    # 'The Daft Punk'
    # [Removed all ?!,.]
    query_string =
        ["name IN (?, ?, ?, ?, ?) OR short_name IN (?, ?, ?, ?, ?, ?)",
          name, name.downcase, 'The ' + name, name.gsub('The ', ''), name.gsub(/[\?\.!,]/, ''),
          name.gsub(' ', '').downcase, name.gsub(/[ \?\.!,]/, '').downcase, name.gsub(' ', '_').downcase, name.gsub(' ', '').upcase, name.downcase.gsub('the ', ''), name.gsub(/[\?\.!,]/, '')
        ]
    band = Band.where(query_string).first
    return band
  end

  def tweets(twitter_client, num_tweets = 3)
  # Takes a Twitter Oauth API client, like that returned from client(true, false, bandID)
  #
    tweet_list = nil
		if self.twitter_user.nil? || twitter_client == nil
			return nil
		else
		  begin
			  tweet_list = twitter_client.user_timeline(:id => self.twitter_user.twitter_id, :count => num_tweets)
			rescue
			  logger.info "Band.tweets error"
			  return nil
			end
		end
		return tweet_list
  end
  
  
  def reward_hashtag
  # Returns a hashtag that our crawler looks for to award shares. Currently set to return the first of the array
  # of twitter_crawler_hash_tags, or band name with spaces removed.
  #
    return (self.twitter_crawler_hash_tags.first && self.twitter_crawler_hash_tags.first.term) || '#' + self.name.gsub(' ', '')
  end

  
  #******************************
  # Statistics
  #******************************

    def tweets_per_day
    # Returns data representing the number of tweets per day for the current object. Called like:
    #   @band.tweets_per_day
    #
    # This function returns an array of data points like the following:
    #   [ [1287903600000, 79], [1287990000000, 25], [1288076400000, 61] ]
    # The first number in each element is Unix time in milliseconds. The second number is the number of tweets that occured on that day for the given band.
    # Returns nil if there are no results.
    #
      tweets = TwitterCrawlerTracker.find_by_sql(
       "SELECT
          DISTINCT t.tweet_id,
          count(date(t.created_at)) as count_for_date,
          date(t.created_at) as date,
          t.*
        FROM twitter_crawler_trackers t
        JOIN twitter_crawler_hash_tags ht
          ON t.twitter_crawler_hash_tag_id = ht.id
        WHERE ht.band_id = #{ self.id }
        GROUP BY date(t.created_at)"
      )
      data_points = tweets.collect{|tweet|
        [Time.parse(tweet.date).to_i*1000, tweet.count_for_date.to_i]
      }

      return (data_points.length == 0) ? nil : data_points
    end


    def num_total_mentions
      TwitterCrawlerTracker.find_by_sql(
       'SELECT DISTINCT tweet_id
        FROM twitter_crawler_trackers
        JOIN twitter_crawler_hash_tags as ht
          ON ht.id = twitter_crawler_trackers.twitter_crawler_hash_tag_id
        WHERE ht.band_id = 1'
      ).count
    end
    
    
    def top_influencers(num_users = nil)
    # Returns an array of Twitter usernames in order of their number of followers on Twitter, or an empty array.
    # Called like @band.top_influencers(10).
    # Example: ["plagosus", "Ruri_Sakuma", "Haeroina", "jaffeon"]
    #
      TwitterCrawlerTracker.joins(
        :twitter_crawler_hash_tag, :twitter_user
      ).where(
        'twitter_crawler_hash_tags.band_id = 1'
      ).includes(
        :twitter_crawler_hash_tag, :twitter_user
      ).order(
        'twitter_followers DESC'
      ).limit(
        num_users
      ).collect{ |a|
        a.twitter_user.user_name
      }.uniq
    end
    
    
    def top_purchasers(num_users = nil)
    # Returns an array of users in order of descending total purchased shares, or an empty array.
    # Called like @band.top_purchasers(10).
    #
      ShareLedgerEntry.where(
        :description => "direct_purchase", :band_id => self.id
      ).joins(
        :user
      ).includes(
        :user
      ).group(
        'user_id'
      ).select(
        'sum(adjustment) as total, *'
      ).order(
        'total DESC'
      ).limit(
        num_users
      ).collect{ |sle|
        sle.user
      }
    end
    
    
    def top_shareholders(num_users = nil)
    # Called like @band.top_shareholders(5). Returns array of ShareTotals or nil.
    # If num_users is nil, returns all the shareholders.
    #
      result = self.get_shareholder_list_in_order(num_users)
      return (result.length == 0) ? nil : result
    end
    
    
    def top_ten_shareholders()
    # Called like Band.first.top_ten_shareholders(), and it returns an array of ShareTotals.
    # Returns either an array of <= 10 ShareTotal objects, or nil if there are 0 shareholders in the band.
    # Example: emails = Band.find(1).top_ten_shareholders.collect { |st| st.user.email }
      self.top_shareholders(10)
    end  

  #******************************
  # /Statistics
  #******************************


  #returns nil or all band shreholders
  def all_shareholder_users()
    return ShareTotal.where(:band_id => self.id).collect{|shareTotal| shareTotal.user}
  end

  
  # returns an array of the sharetotal joined to user entries while specifying the limit, returns empty array, or array with share totals
  def get_shareholder_list_in_order(limit=nil)
    # The more senioruser wins in a tie
    # result = ShareTotal.find_by_sql("
    #               SELECT * FROM share_totals
    #                 INNER JOIN users ON users.id = share_totals.user_id
    #                 WHERE band_id = #{ self.id }
    #                 ORDER BY net DESC, users.created_at ASC
    #                 LIMIT 10
    #              ")
    #    result = ShareTotal.where(:band_id => self.id).joins(:user).includes(:user).order('share_totals.net DESC, users.created_at ASC').limit(10)        
    return ShareTotal.where(:band_id => self.id).joins(:user).includes(:user).order('share_totals.net DESC, share_totals.created_at ASC').limit(limit).all      
  end
  
  
  # Image helper
  def path_to_headline_photo(thumbnail_key)
    if path_to_photo = Photo.find_by_id(self.headline_photo_id)
      path_to_photo = path_to_photo.public_filename(thumbnail_key)
    else
      path_to_photo = NO_IMAGE_PATHS[thumbnail_key]
    end
    return path_to_photo
  end
  
  # ***********************
  # END
  
  
  #******************************
  # Associations and permissions 
  #******************************
  
  def admins #returns all admin users
    return self.associations.find_all_by_name('admin', :joins => :user).collect{|a| a.user}.uniq
  end
  
  def members #returns all memeber users
    return self.associations.find_all_by_name('member', :joins => :user).collect{|a| a.user}.uniq
  end
=begin   
  def has_friend_by_user_id(user_id)
    return self.associations.find_by_user_id_and_name(user_id, 'watching')
  end
=end      
  
  #NOTE: figure out a way to cache this, sure we could have it as a part of the bands table, but it really should all be executed in code and just heavily cached -- this allows more flexible roll authoring
  def fan_association
    return self.associations.find_by_name(self.short_name + "_fan")
  end
  
  #NOTE: figure out a way to cache this, sure we could have it as a part of the bands table, but it really should all be executed in code and just heavily cached
  def member_association
    return self.associations.find_by_name(self.short_name + "_member")
  end
  
  def admin_association
    return self.association.find_by_name(self.short_name + "_admin")
  end  
  
protected

  
  def generate_secret_token()
  # Set secret_token to be 40 randomish characters.
  #
    self.secret_token = Digest::MD5.hexdigest(SecureRandom.random_bytes(4))
    return true
  end


end

