class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :promotional_codes
  has_many :associations, :dependent => :destroy
  has_many :bands, :through => :associations, :uniq => true
  has_many :invested_in_bands, :through => :share_totals, :source => "band"
  belongs_to :state
  belongs_to :country
  belongs_to :twitter_user
  has_many :live_stream_series_permissions
  has_many :streamapi_stream_viewer_statuses
  has_many :short_urls, :as => :maker # A shortened URL might have a "maker", which could refer to a band or a user.
  has_many :share_totals
  has_many :share_ledger_entries
  has_many :transactions
  has_many :pledges
  has_many :authentications
  
  before_save :expand_zipcode # Populates state and country from zipcode
  validates :email, :email => true
  validates_presence_of :email
  validates_presence_of :password
  validates_confirmation_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :twitter_user_id, :unless => Proc.new {|user| user.twitter_user_id.nil? || user.twitter_user_id == ''}
  validates_numericality_of :phone, :unless => Proc.new {|user| user.phone.nil? || user.phone == ''}
  validates :email, :email => true
  validates_length_of :first_name, :minimum => 1, :unless => Proc.new {|user| user.first_name.nil? || user.first_name == ''}
  validates_length_of :first_name, :maximum => 20, :unless => Proc.new {|user| user.first_name.nil?}
  validates_length_of :last_name, :maximum => 25, :unless => Proc.new {|user| user.last_name.nil?}
  validates_length_of :address1, :maximum => 100, :unless => Proc.new {|user| user.address1.nil?}
  validates_length_of :address2, :maximum => 100, :unless => Proc.new {|user| user.address2.nil?}
  validates_length_of :zipcode, :minimum => 1, :unless => Proc.new {|user| user.zipcode.nil? || user.zipcode == ''}
  validates_length_of :zipcode, :maximum => 15, :unless => Proc.new {|user| user.zipcode.nil?}
  validates_length_of :email, :maximum => 100, :unless => Proc.new {|user| user.email.nil?}
  validates_length_of :phone , :maximum => 20, :unless => Proc.new {|user| user.phone.nil?}
  
  API_ATTRIBUTES = %w(first_name last_name email)
  def api_attributes
    self.attributes.reject{|k, v| !API_ATTRIBUTES.include?(k.to_s)}
  end
  def twitter_client
    twitter_user_account = self.twitter_user
    if twitter_user_account
      return twitter_user_account.client
    end
    return nil
  end

  def generate_or_salt_password(password=generate_key(8))
  	#create salted password
    random = ActiveSupport::SecureRandom.hex(10)
    salt = Digest::SHA2.hexdigest("#{Time.now.utc}#{random}")
    salted_password = Digest::SHA2.hexdigest("#{salt}#{password}")
    self.password_salt = salt
    self.password = salted_password
  end
  def self.authenticate(passed_email, passed_password)
    ( user = User.find_by_email(passed_email) ) && (( user.password_salt.blank? && user.password == Digest::SHA2.hexdigest(passed_password) ) || (!user.password_salt.blank? && user.password == Digest::SHA2.hexdigest("#{user.password_salt}#{passed_password}")))    
  end
  #will return the twitter user through the authentications join table
  def twitter_user
    auth = self.authentications.find_by_provider('twitter')
    twitter = nil
    if auth
      twitter = TwitterUser.find_by_twitter_id(auth.uid)
    end
    return twitter
  end
  def authenticated_with_twitter?
    twitter_user_account = self.twitter_user
    if twitter_user_account
      return twitter_user_account.authenticated?
    end
    return false
  end

  def num_retweets_in_band_in_past_day(band_id=nil)
    if band_id == nil || self.twitter_user.blank?
      return 0
    end
    return Retweet.where(:band_id => band_id, :twitter_user_id => self.twitter_user.id).where("created_at > ?", 1.day.ago).count
  end
  








  #will return the facebook user through the authentications join table  
  def facebook_user
    auth = self.authentications.find_by_provider('facebook')
    facebook = nil
    if auth
      facebook = FacebookUser.find_by_facebook_id(auth.uid)
    end
    return facebook
  end
  
  #takes an omniauth callback and fill in as much user information as possible
  def apply_omniauth(omniauth, params)
    if omniauth && omniauth['user_info'] && omniauth['provider'] && omniauth['uid']
      if omniauth['provider'].to_s.downcase == 'facebook' && omniauth['extra'] && omniauth['extra']['user_hash'] && omniauth['extra']['user_hash']['email']
        self.email = omniauth['extra']['user_hash']['email'].to_s if email.blank?
      end
      self.first_name = omniauth['user_info']['name'].to_s.split[0] if first_name.blank?
      self.last_name = omniauth['user_info']['name'].to_s.split[1] if last_name.blank?
      authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    end
  end
  
  #this method will award bandstock to the user for tweets they made in the past (for new users who sign up, or users who tie in a twitter account)
  def reward_tweet_bandstock_retroactively
    #award bandstock for hash_tags and phrases
    if self.twitter_user
      not_yet_awarded_tweets = self.twitter_user.twitter_crawler_trackers.where(:shares_awarded => false).all
    
      for tweet in not_yet_awarded_tweets
        unless tweet.share_value == 0
          ShareLedgerEntry.create( :user_id => self.id,
                                          :band_id => tweet.twitter_crawler_hash_tag.band.id,
                                          :adjustment => tweet.share_value,
                                          :description => 'tweeted_band_retroactively_awarded'
                              )
        end
        tweet.shares_awarded = true
        tweet.save
      end    
    else
      return false
    end
  end
  
  
  def share_totals
    ShareTotal.where(:user_id => self.id).all
  end

  # -1 for downward movement, 0 for stable, 1 for upward movement, nil for not a shareholder
  def rank_in_band_movement(band_id)
    share_total = ShareTotal.where(:user_id => self.id, :band_id => band_id).first
    if share_total.blank?
      return nil
    end
    
    #moved down
    if share_total.last_rank < share_total.current_rank
      return -1
    #moved up
    elsif share_total.last_rank > share_total.current_rank
      return 1
    else
      return 0
    end    
  end

  def shareholder_rank_for_band(band_id)
  # Takes a band ID, and return's the user object's rank. or false

    return false if band_id.nil?
    
    band = Band.find(band_id)
    user_share_total = ShareTotal.where(:user_id => self.id, :band_id => band.id).first
    if user_share_total.nil?
      return false
    else
      return band.get_shareholder_list_in_order.index(user_share_total)+1
    end
    
    #  # Current tie resolution scheme: date of user registration
    #  share_total = self.share_totals.where(:band_id => band_id).first
    #  num_shares = (share_total) ? share_total.net : 0
    #  
    #  # The more senior user wins in a tie
    #  ShareTotal.find_by_sql(["
    #              SELECT * FROM share_totals
    #                INNER JOIN users ON users.id = share_totals.user_id
    #                WHERE band_id = #{ band_id }
    #                AND net > #{ num_shares }
    #                OR (net = #{ num_shares } AND users.created_at < ?)
    #             ", self.created_at] ).count + 1
    
    # Lexicographic email tie resolution:
    # ShareTotal.find_by_sql("
    #         SELECT * FROM share_totals
    #           INNER JOIN users ON users.id = share_totals.user_id
    #           WHERE band_id = #{ band_id }
    #           AND net > #{ num_shares }
    #           OR  (net = #{ num_shares } AND users.email < '#{ self.email }')
    #     ").count + 1
  end

  #**********************
  # User privileges
  #**********************          

  def set_privilege(user = nil, priv_hash = nil)
  # Takes a user object, then applies the privileges specified in the hash.
  # Input priv_hash looks like:
  #   { :can_view => 1, :can_listen => 0, :stream_quality_level => 'high' }
  # where can_view is set to 1, etc, and can_chat is left alone (because it was unspecified)

  # TODO streamseries_permissionObject.update(hash)
  #   http://api.rubyonrails.org/classes/ActiveRecord/Base.html#M002270
    
    if (priv_hash.nil? || email.nil?)
      return false
    end

    possible_privs = [:can_view, :can_chat, :can_listen, :stream_quality_level]

    priv_hash.each do |priv_name, priv_value|
      # Skip if priv_value is nil, 'nil' (from the API test tool), or if priv_value is not one of 1 or 0
      unless (  priv_value.nil? ||
                priv_value == 'nil' ||
                (priv_value != 1 || priv_value != 0) ||
                !possible_privs.include?(priv_name)
              )
        
        user[priv_name] = priv_value
      end
    end

    #if (can_view == 0)  # We're explicit about input values
    #  user.can_view = 0
    #elsif (can_view == 1)
    #  user.can_view = 1

    return true
  end
   
  #************************************
  # Methods for quick and cached stats
  #************************************ 
  
  
  ### A bunch of location methods
  def location_zoom_street
    return append_country( append_state( append_city( append_street('') ) ) )
  end
  
  def location_zoom_city
    return append_country( append_state( append_city('') ) )
  end
  
  def location_zoom_zip
    return append_country( append_state( append_zipcode('') ) )
  end
  
  def location_zoom_state
    return append_country( append_state('') )
  end
  
  def append_street(ret_string)
    if ( (self.address1 != '') && (self.address1) )
      if (ret_string != '')
        ret_string += ", #{self.address1}"
      else
        ret_string += self.address1
      end
    end
    return ret_string
  end
  
  def append_city(ret_string)
    if ( (self.city != '') && (self.city) )
      if (ret_string != '')
        ret_string += ", #{self.city}"
      else
        ret_string += self.city
      end
    end
    return ret_string
  end
  
  def append_zipcode(ret_string)
  end
  
  def append_state(ret_string)
    if ( self.state )
      if (ret_string != '')
        ret_string += ", #{self.state.name}"
      else
        ret_string += self.state.name
      end
    end
    return ret_string
  end
  
  
  def append_country(ret_string)
    if ( self.country )
      if (ret_string != '')
        ret_string += ", #{self.country.name}"
      else
        ret_string += self.country.name
      end
    end
    return ret_string
  end
  
  ### End Location Methods
  ########################
  
  
  def full_name
    return (first_name || '') + " " + (last_name || '')
  end
  

  def display_name
  # Returns a proper, non-email address display name. One of the following is used, in order of preference:
  #   first_name
  #   text_before_the@symbol.com, from the user's email address
  #   [No name]
  #
    email_username = email[0, email.index('@') || 0]  # Text before the @
    email_username = (email_username == '') ? '[No name]' : email_username
    output = (first_name && !first_name.strip.empty?) ? first_name : email_username
    return output
  end
  

  def self.display_name(email, first_name)
  # Returns a proper, non-email address display name.
  # Takes two strings (all can be nil):
  #   email, first_name
  # One of the following is used, in order of preference:
  #   first_name
  #   text_before_the@symbol.com, from the user's email address
  #   [No name]
  #
    email_username = email[0, email.index('@') || 0]  # Text before the @
    email_username = (email_username == '') ? '[No name]' : email_username
    output = (first_name && !first_name.strip.empty?) ? first_name : email_username
    return output
  end
  

  def display_location
  # Returns, in order of preference, one of: explicit state abbreviation, state abbreviation obtained by zipcode, or nil
  # Like: 'CA'
  #
    state = self.state
    if state && state.abbreviation
      location = state.abbreviation
    elsif self.zipcode && zip_row = Zipcode.where(:zipcode => self.zipcode).first
      location = (zip_row.abbr) ? zip_row.abbr : nil
    else
      location = nil
    end
    return location
  end
  
  
  #**********************
  # ROLES AND AUTH STUFF
  #**********************          

 
  def toggle_role(role_id)
    unless ( (r = Role.find(role_id)) && (ur = self.roles.find_by_id(role_id)) )
      user_role = self.roles << Role.find(role_id)
    else
      self.roles.delete(r)
    end
  end
  
  def has_band_admin(passed_band_id)
    #THIS FUNCTION TAKES AN INTEGER
    #I recast anyway below, but if things are harry check the cast or just pass an integer.
    if self.site_admin
      return true
    else
    #modified for rails 3
      return self.associations.where(:name => 'admin').where(:band_id => passed_band_id).first
    end
  end


  def is_member_of_band(passed_band_id)
    #THIS FUNCTION TAKES AN INTEGER
    if self.site_admin
      return true
    else
    #modified for rails 3    
      return self.associations.where(['name = ? AND band_id = ?', 'member', passed_band_id.to_i]).first
    end
  end

  def can_broadcast_for(band_id)
  # Takes an integer band ID and returns true if the user is a member or admin of the band.
    return ( self.has_band_admin(band_id) || self.is_member_of_band(band_id) || self.site_admin )
  end

  def can_view_series(live_stream_series_id)
    # Takes an ID of a LiveStreamSeries and returns true if the user can view it, false otherwise
    # The user can view if any of the following is met:
    #   User has view permission in LiveStreamSeriesPermission, or
    #   he is a site admin, or
    #   he can broadcast for the band
  
    lssp = self.live_stream_series_permissions.where(:live_stream_series_id => live_stream_series_id).first
    can_view = (
                  (lssp && lssp.can_view) ||
                  (lssp && self.can_broadcast_for(lssp.live_stream_series.band.id)) ||
                  self.site_admin
                )
    return can_view
  end


  def has_role?(name=nil,id=nil)
    if (name == nil && id == nil)
      return false
    end

    unless id.nil?
      if self.roles.collect{|r| r.id}.include? id
        return true
      end
    else
     if self.roles.collect{|r| r.name}.include? name
        return true
      end
    end

     #nothing found so return false
    return false
  end
  
  def is_part_of_a_band?
    return !self.associations.reject {|a| a.name == "fan"}[0].nil?  
  end

  def is_admin_of_a_band?
    if self.site_admin
      return true 
    else
      return !self.associations.reject{|a| a.name =="fan" || a.name == "member"}[0].nil?
    end
  end
 
  def site_admin
    return self.has_role?('site_admin', nil)
  end

  private
  
  def expand_zipcode
  # Populates a user's state and country fields, if they are not specified and a zipcode is specified.
    if (self.zipcode)
      zip_row = Zipcode.where(:zipcode => self.zipcode).first
      if zip_row
        self.state = self.state || State.where(:abbreviation => zip_row.abbr).first
        self.city = self.city || zip_row.city        
      end
    end
    return true
  end
  def generate_key(length = 16)
  # Takes a string length and returns a random string
    chars = ("a".."z").to_a + ('A'..'Z').to_a + ("0".."9").to_a;
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end
end
