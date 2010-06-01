class User < ActiveRecord::Base

  has_and_belongs_to_many :roles
  has_many :associations, :dependent => :destroy
  has_many :bands, :through => :associations, :uniq => true
  belongs_to :state
#  has_many :earned_perks, :dependent => :destroy
#  has_many :perks, :through => 'earned_perks', :dependent => :destroy
#  has_many :emails, :through => 'emails', :dependent => :destroy
  belongs_to :country
#  has_many :contributions, :dependent => :destroy
#  has_many :invested_artists, :through => :contributions, :source => :band, :uniq => true
  
#  has_many :user_friends, :foreign_key => 'source_user_id'
#  has_many :friends, :through => :user_friends, :source => 'destination'
  
#  has_many :google_checkout_orders
#  has_many :user_photos
 
  has_many :live_stream_series_permissions
  has_many :streamapi_stream_viewer_statuses

  #validations -- goes down to the first def
  
  #empty?
  validates_presence_of :email
  validates_presence_of :password
  validates_presence_of :password_confirmation, :on => :create
  validates_confirmation_of :password, :on => :create
  #validates_acceptance_of :agreed_to_tos, :accept => true, :message => "- You must agree to our Terms of Service to register"
  #validates_acceptance_of :agreed_to_pp, :accept => true, :message => "- You must agree to our Privacy Policy to register"

  #field specific
#  validates_uniqueness_of :nickname
  validates_uniqueness_of :email
  validates_numericality_of :zipcode, :unless => Proc.new {|user| user.zipcode.nil? || user.zipcode == ''}
  validates_numericality_of :phone, :unless => Proc.new {|user| user.phone.nil? || user.phone == ''}
#  validates_numericality_of :country_id
  
  #length
  #the length of these is maxed by the field width in the database.  And that width was chosen rather arbitrarily - while being long enough to be safe.
#  validates_length_of :nickname, :maximum => 50, :unless => Proc.new {|user| user.nickname.nil?}
  
  #validates_length_of :password, :maximum => 50, :unless => Proc.new {|user| user.password.nil?} --- commented because all hashes now are going to be 40/64 characters long
  validates_length_of :password, :minimum => 6, :unless => Proc.new {|user| user.password.nil?}
  
  validates_length_of :first_name, :minimum => 1, :unless => Proc.new {|user| user.first_name.nil? || user.first_name == ''}
  validates_length_of :first_name, :maximum => 50, :unless => Proc.new {|user| user.first_name.nil?}
  validates_length_of :last_name, :maximum => 50, :unless => Proc.new {|user| user.last_name.nil?}
  validates_length_of :address1, :maximum => 100, :unless => Proc.new {|user| user.address1.nil?}

  validates_length_of :address2, :maximum => 100, :unless => Proc.new {|user| user.address2.nil?}
  validates_length_of :zipcode, :minimum => 1, :unless => Proc.new {|user| user.zipcode.nil? || user.zipcode == ''}
  validates_length_of :zipcode, :maximum => 10, :unless => Proc.new {|user| user.zipcode.nil?}
  validates_length_of :email, :maximum => 75, :unless => Proc.new {|user| user.email.nil?}
  validates_length_of :phone , :maximum => 20, :unless => Proc.new {|user| user.phone.nil?}

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
  
  # ***************
  # Image helper
  
=begin  def path_to_headline_image(thumbnail_key)
    if path_to_image = UserPhoto.find_by_id(self.headline_photo_id)
      path_to_image = path_to_image.public_filename(thumbnail_key)
    else
      path_to_image = NO_IMAGE_PATHS[thumbnail_key]
    end
    return path_to_image
  end
  
  
  def unread_mail
    return self.band_mails.find_all_by_opened(false)
  end
  
  
  def new_friends_yesterday
    0
  end
  
  def shares_donated_to_band(band_id)
    return Contribution.find_all_by_user_id_and_band_id(self.id, band_id, :include => :contribution_level).collect {|c| c.contribution_level.number_of_shares}.sum
  end

  
  def contributions_made_to_band(band_id)
    return self.contributions.find_all_by_band_id(band_id, :joins => :contribution_level)
  end
  #the following is a great proponent for caching, once the first association is made it'll always be the earliest

  def date_associated_with_band(band_id)
    a = Association.find_by_user_id_and_band_id(self.id, band_id, :order => "by created_at desc")
    if (a.nil?)
      return "Never"
    else
      return a.created_at.to_s
    end
  end
       
  
  
  # ********
  # Friend Actions
  def has_friend_by_id(user_id)
    return UserFriend.find_by_source_user_id_and_destination_user_id(user_id, self.id)
  end
  
  def is_friends_with_user_id(user_id)
    return UserFriend.find_by_source_user_id_and_destination_user_id(self.id, user_id)
  end
  
  # End Friend Actions
  # *********
  
  
  def total_shares
    return  self.contributions.find(:all, :joins => :contribution_level).collect{|c| c.contribution_level.number_of_shares}.sum
  end    
  
  
  def net_worth
    #this will have to work for now
    return self.total_shares
  end
  
  
  def earned_perks_from_band(target_band)
    #yes,this takes a band object, not a band_id
    return self.earned_perks.find_all_by_band_id(target_band.id)
    
  end
  
  
  def top_friends
    return Contribution.find(:all, :select => ['user_id, users.nickname as nickname, sum(number_of_shares) as tot_shares'], :joins => [:contribution_level, :user], :conditions => ['user_id IN (?)', self.friends.collect{|f| f.id}], :order => ['tot_shares desc'], :group => ['user_id'], :limit => 10)
    
  end
  
  
  def top_invested_artists
    return Band.find(:all, :select => ['contributions.band_id as band_id, bands.name as name, sum(number_of_shares) as total'], :joins => [{:contributions => :contribution_level}], :conditions => ['contributions.user_id = ?', self.id], :order => ['total desc'], :group => ['band_id'], :limit => 10)
    
  end
=end       
  
  
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
      return self.associations.where(['name = ? AND band_id = ?', 'admin', passed_band_id.to_i]).first
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
  
    lssp = self.live_stream_series_permissions.find_by_live_stream_series_id(live_stream_series_id)
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

  # END PERMS METHODS

  # **************
  # PERKS
  # *************
=begin  
  def grant_perk(input_hash)
    user_perk = EarnedPerk.new do |p|
      p.perk_id = input_hash[:perk_id]
      p.contribution_level_id = input_hash[:contribution_level_id]
      p.band_id = Perk.find(input_hash[:perk_id]).band.id
      p.user_id = self.id
      p.filled = input_hash[:filled]
      p.confirmed = false
      p.google_checkout_order_id = input_hash[:google_checkout_order_id]
      p.save
    end
  end
=end  
  
  
end
