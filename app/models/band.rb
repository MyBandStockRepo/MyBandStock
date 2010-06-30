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
  
#  has_many :contribution_levels, :dependent => :destroy
#  has_many :perks, :dependent => :destroy
#  has_many :contributions, :dependent => :destroy
#  has_many :contributors, :through => :contributions, :source => :user, :uniq => true
#  has_many :band_statistics, :dependent => :destroy
#  has_many :earned_perks, :dependent => :destroy

#  has_many :news_entries, :dependent => :destroy
#  has_many :concerts, :dependent => :destroy
#  has_many :stage_comments, :dependent => :destroy
#  has_many :photos, :dependent => :destroy
#  has_many :songs, :dependent => :destroy
#  has_many :projects, :dependent => :destroy

#  has_many :photo_albums, :dependent => :destroy
#  has_many :music_albums, :dependent => :destroy

#  has_many :band_mails
  #has_many :received_mail, :through => 'band_mail', :source => 'BandMail', :conditions => 'from_band = 0'
  
  validates_presence_of :name, :country_id, :zipcode, :city, :short_name
#  validates_acceptance_of :terms_of_service, :accept => true, :message => "You must agree to our terms of service."
  validates_numericality_of :zipcode, :country_id
  validates_uniqueness_of :short_name
  validates_length_of     :short_name, :in => 3..14
  validates_exclusion_of  :short_name, :in => %w[
      admin application bands charts concerts contests contribution_levels
      earned_perks ledger_entries legal login merchant music_albums news_entries
      perks photo_albums photos projects search songs stage_comments users],
    :message => 'Sorry, but that shortname conflicts with a list of words reserved by the website.'

  def tweets(twitter_client, num_tweets = 3)
  # Takes a Twitter Oauth API client, like client(true, false, bandID)
    #
    logger.info "In band.tweets"
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
    # JOIN with user?
    ShareTotal.where(:band_id => self.id).limit(10).order('net DESC').all.collect{ |a| a.user }
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
