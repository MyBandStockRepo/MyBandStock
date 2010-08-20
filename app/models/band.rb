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
  
#  has_many :contributions, :dependent => :destroy
#  has_many :contributors, :through => :contributions, :source => :user, :uniq => true

#  has_many :stage_comments, :dependent => :destroy
#  has_many :photos, :dependent => :destroy

#  has_many :band_mails
  #has_many :received_mail, :through => 'band_mail', :source => 'BandMail', :conditions => 'from_band = 0'
  
  validates_presence_of :name, :country_id, :zipcode, :city, :short_name
#  validates_acceptance_of :terms_of_service, :accept => true, :message => "You must agree to our terms of service."
  validates_numericality_of :zipcode, :country_id
  validates_uniqueness_of :short_name
  validates_length_of     :short_name, :in => 3..15
  validates_exclusion_of  :short_name, :in => %w[
      admin application bands charts concerts contests contribution_levels
      earned_perks ledger_entries legal login merchant music_albums news_entries
      perks photo_albums photos projects search songs stage_comments users],
    :message => 'Sorry, but that shortname conflicts with a list of words reserved by the website.'
  validates_format_of     :short_name, :with => /^[\w]{3,15}$/, :message => "Must have only letters, numbers, and _."
  
    
  def available_shares_for_purchase
  # Returns the number of shares available for purchase for the band, for this time period.
  # Shares are only limited in the contexts of direct purchases. That is, someone can always retweet for shares,
  #   but direct dollar-for-share purchases are limited.
  # Dependents:
  #   NUM_SHARES_PER_BAND_PER_DAY - in environment.rb, setting the limit for the amount of available shares/band/day
  #   SHARE_LIMIT_LIFETIME        - in environment.rb, dictating the period of time between new share releases
  #   ^^nevermind, too hard. It's just one day.
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
    
    available_shares = NUM_SHARES_PER_BAND_PER_DAY - dispersed_shares_sum
    available_shares = (available_shares >= 0) ? available_shares : 0
    
    return available_shares
  end
  
  
  def share_price()
  # This method returns the price per share for the given band.
  # Currently, the share price is simply a static constant, defined in environment.rb.
  #
    return Cobain::Application::MBS_SHARE_PRICE
  end

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
  # Takes a Twitter Oauth API client, like client(true, false, bandID)
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
  
  def top_ten_shareholders()
  # Called like Band.first.top_ten_shareholders(), and it returns an array of ShareTotals.
  # Returns either an array of <= 10 ShareTotal objects, or nil if there are 0 shareholders in the band.
  # Example: emails = Band.find(1).top_ten_shareholders.collect { |st| st.user.email }
  #
    # The more senior user wins in a tie
    # result = ShareTotal.find_by_sql("
    #               SELECT * FROM share_totals
    #                 INNER JOIN users ON users.id = share_totals.user_id
    #                 WHERE band_id = #{ self.id }
    #                 ORDER BY net DESC, users.created_at ASC
    #                 LIMIT 10
    #              ")
    result = ShareTotal.where(:band_id => self.id).joins(:user).includes(:user).order('share_totals.net DESC, users.created_at ASC').limit(10)

    return (result.length == 0) ? nil : result
  end

  #returns nil or all band shreholders
  def all_shareholder_users()
    return ShareTotal.where(:band_id => self.id).collect{|shareTotal| shareTotal.user}
  end
  
  #####
  #stats and quick data retrieval methods
  #####
=begin  
  def concerts_after_now
    return self.concerts.find(:all, :conditions => ['date > NOW()'])
  end
  
  
  def stage_comments_yesterday
    return self.stage_comments.find(:all, :conditions => ['created_at > ? AND created_at < ?', 1.day.ago.midnight, Time.now.midnight])
  end
  
  def unread_mail
    return self.band_mails.find_all_by_opened(false)
  end
  
  def new_watchers_yesterday
    return self.associations.find(:all, :conditions => ['created_at > ? AND created_at < ? AND name = ?', 1.day.ago.midnight, Time.now.midnight, 'watching'])
  end
  
  
  def net_worth
    #this will work for now.  If updated make sure to update in concert with the net_worth action on the user model
    return self.stocks_sold
  end
  
  
  def flagged_perks
    return 0
  end
  
  
  def total_fans
    return self.contributors.size
  end
  
  
  def stocks_sold
    return self.contributions.collect{|x| x.contribution_level.number_of_shares}.sum
  end
  
  
  def active_project
    return self.projects.find_by_active(1)
  end
  
  
  def top_fans
    #Caches out of the box! 
    return Rails.cache.fetch("band_#{self.id}_top_fans", :expires_in => 1.hour) { Contribution.find(:all, :select => ['user_id, users.nickname, sum(number_of_shares) as tot_shares'], :joins => [:contribution_level, :user], :conditions => ['contributions.band_id = ?', self.id], :group => 'user_id', :order => ['tot_shares desc'], :limit => 15) }
    
  end
  
  
  def filled_perks
    return self.earned_perks.find_all_by_filled_and_flagged(true,false).length
  end
  
  
  def unfilled_perks
    return self.earned_perks.find_all_by_filled(false).length
  end
  
  def new_fans_last_week
    return Rails.cache.fetch("band_#{self.id}_new_fans_last_week", :expires_in => (Time.now.end_of_week.end_of_day - Time.now) ) {
      created_last_week = self.contributions.find(:all, :conditions => ['created_at > ? AND created_at < ?', 7.days.ago.beginning_of_week.midnight, Time.now.beginning_of_week.midnight]).collect{|c| c.user_id}
      created_previous_users = self.contributions.find(:all, :conditions => ['created_at < ?', 7.days.ago.beginning_of_week.midnight]).collect{|c| c.user_id}
      created_last_week_new = ( created_last_week - created_previous_users ).size
    }
  end
  
  def playlist_songs
    return self.songs.find(:all, :conditions => ['playlist_position is NOT NULL AND thumbnail is NULL'], :order => 'playlist_position ASC')
  end
  
  def playlist_url
    return SITE_URL+'/files/playlists/'+self.id.to_s+'_main.xml'
  end

  # ********************
  # Utility Methods
  # ********************
  
  def update_playlist_xml
    songs = self.songs.find(:all, :conditions => ['playlist_position is NOT null'], :order => 'playlist_position ASC')
    builder = Builder::XmlMarkup.new
    xml = builder.playlist(:artist => self.name) do |p|
      for song in songs
        if song.music_album
          album_title = song.music_album.name
        else
          album_title = 'Unreleased'
        end
        streamable = Song.find(:first, :conditions => ['parent_id = ? AND thumbnail = ?', song.id, 'lq_stream'])
        p.song(:name => song.name, :artist_name => song.band.name, :album_title => album_title, :length => streamable.length.to_s, :filename => streamable.id.to_s, :file_type => 'mp4', :stream_url => STREAMS_URL, :file_size => song.size)
      end
    end

    f = File.new("#{RAILS_ROOT}/public/files/playlists/#{self.id}_main.xml",  "w+")  
    f << xml
    f.close
    File.chmod(0755, "#{RAILS_ROOT}/public/files/playlists/#{self.id}_main.xml" )
  end
=end
  # ***************
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

end
