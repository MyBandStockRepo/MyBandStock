require 'net/http'
require 'uri'
require 'rexml/document'
include REXML

class BandsController < ApplicationController
  
 protect_from_forgery :only => [:create, :update]
 before_filter :authenticated?, :except => [:show, :is_band_broadcasting_live, :index]
# skip_filter :update_last_location, :except => [:index, :show, :control_panel, :manage_users, :manage_project, :manage_music, :manage_photos, :manage_perks, :manage_fans, :inbox]
 before_filter :user_is_admin_of_a_band?, :except => [:show, :create, :new, :buy_stock, :is_band_broadcasting_live, :index]
 skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :control_panel, :manage_users]

# returns a json object about if the band is currently broadcasting
 def is_band_broadcasting_live
   is_live = false
   output = Hash.new
   
   output[:next_stream_starts_at] = nil
   if params[:band_id]
     band = Band.find(params[:band_id])
     
     current_broadcasts = band.current_broadcast_streams

     if current_broadcasts.nil? || current_broadcasts.count == 0
       next_stream = band.next_stream
     
       unless next_stream.nil?
         is_live = next_stream.currently_live
         output[:next_stream_starts_at] = output_datetime(next_stream.starts_at)
         output[:view_link] = {
           :url => url_for( :controller => 'streamapi_streams', :action => 'view', :id => next_stream.id, :lightbox => params[:lightbox] ),
           :width => 880, #(theme) ? theme.width+50 : 560,
           :height => 480 #(theme) ? theme.height+115 : 580
         }
       end
     else
       #here
       is_live = true
       output[:view_link] = {
         :url => url_for( :controller => 'streamapi_streams', :action => 'view', :id => current_broadcasts.first.id, :lightbox => params[:lightbox] ),
         :width => 880, #(theme) ? theme.width+50 : 560,
         :height => 480 #(theme) ? theme.height+115 : 580
       }
       
     end
     
   end
   
   output[:is_live] = is_live
  
   output_json = output.to_json
   
   return render :json => output_json, :callback => 'bandIsBroadcastingJsonCallback'
 end

  def index
    
    @official_bands = Band.where(:mbs_official_band => true).order('id DESC')
  #  @top_pledged_bands = PledgedBand.order('pledges_count DESC').limit(5)
    
  end
  
  def show
    id = get_band_id_from_request()
    if id.nil? && params[:id]
      # User went to something like /bands/the+killers, so redirect him to the band search page
      redirect_to :controller => 'fans', :action => 'store_band_name', :band => { :search_text => params[:id] }
      return false
    end
    begin
      @band = Band.includes(:live_stream_series).find(id)
    rescue ActiveRecord::RecordNotFound
      # No band exists by that ID. This could also have been an attempt to navigate to '/corporate' or something.
      # So we redirect to 404
      redirect_to status_404_path(:requested_page => params[:band_short_name]) and return
    end
		@request_uri = url_for()
		@body_id = 'band_stage'
		@user = User.where(:id => session[:user_id]).first
    @can_broadcast = ( session[:user_id] && @user && @user.can_broadcast_for(@band.id) )
    @top_ten = @band.top_ten_shareholders
    @user_rank = (@user) ? @user.shareholder_rank_for_band(id) : (ShareTotal.where(:band_id => id).where('net > 0').count + 1)
    @twitter_username = if !@band.twitter_username.blank?
                          @band.twitter_username
                        elsif @band.twitter_user && @band.twitter_user.user_name
                          @band.twitter_user.user_name
                        else
                          nil
                        end

    @recent_statuses = @band.status_feed()

    # Twitter authentication can redirect to this band show page. If the user just authorized with Twitter,
    #   We shall notify the view to pop open the retweet lightbox because the user is currently in the process of retweeting.
    if session[:user_just_authorized_with_twitter]
      # Twitter_api#finalize sets this session variable.
      session[:user_just_authorized_with_twitter] = false
      @currently_tweeting = true
    end
    
    # If the user was just referred here from the band's site, display the welcome message. Then set the cookie so
    #   it doesn't open again.
    if ( came_from_band_site(@band) && cookies[:supress_welcome_popup].blank? )
  		@show_welcome_message = true
  		cookies[:supress_welcome_popup] = true
  	end

    #make sure the band isn't hidden
    if @band.status != "active"
      render :action => 'is_hidden'
    end

    if (@band && @band.live_stream_series )
      # Prod can't handle caching
      #@live_stream_series = Rails.cache.fetch "band_#{@band.id}_live_stream_series" do 
      #  @band.live_stream_series.includes(:streamapi_streams).all
      #end
      @live_stream_series = @band.live_stream_series.includes(:streamapi_streams).order('streamapi_streams.starts_at ASC').all
    end

    begin
			unless @band.twitter_user
				@band_twitter_authorized = false
			else
				band_client = client(true, false, @band.id)
				@twit_band = band_client.verify_credentials
				@band_twitter_authorized = true	
				@band_tweets = @band.tweets(band_client, 5) #.user_timeline(:id => @twit_band.id)
			end		
		rescue
				@band_twitter_authorized = false
		end					
		begin
			if session[:user_id] && @user = user
				unless @user.twitter_user
					@user_twitter_authorized = false
				else
					@twit_user = client(false, false, nil).verify_credentials
					@user_twitter_authorized = true			
				end		    
			end    
		rescue
			@user_twitter_authorized = false
		end
    
  end
  
  
  def edit
  
    unless id = get_band_id_from_request()
      return false
    end
		@request_uri = url_for()
    @band = Band.find(id)
    #check and make sure only an authorized user can edit
    unless User.find(session[:user_id]).has_band_admin(@band.id)
      redirect_to '/stage/'
    end
    
    unless @band.country_id.nil?
      @states = State.find_all_by_country_id(@band.country_id)
    else
      @states = nil
    end
    
    begin
			unless @band.twitter_user
				@band_twitter_authorized = false
			else
				band_client = client(true, false, @band.id)
				@twit_band = band_client.verify_credentials
				@band_twitter_authorized = true										
			end		
		rescue
				@band_twitter_authorized = false
		end					
    
    respond_to do |format|
      format.html{}
      format.js {
                render :partial => 'bands/form'
                }
    end
  end
  
  
  def new
  
    #bring in the user first and last name
    @user = User.find(session[:user_id])
    #see if they have an approved application
=begin
    unless ( @application = @user.band_applications.find_by_approved_and_created(true, false) )
      redirect_to session[:last_clean_url]
      return false
    end
=end    
    #check to see if they've been around before
    if params[:band]
      @band = Band.new(params[:band])
    else
      @band = Band.new
    end
		begin
			unless @band.twitter_user
				@band_twitter_authorized = false
			else
				band_client = client(true, false, @band.id)
				@twit_band = band_client.verify_credentials
				@band_twitter_authorized = true										
			end		
		rescue
				@band_twitter_authorized = false
		end					    
    if (@band.country_id.nil? || @band.country_id == '' )
      #calculate their ip number to determine country of origin
      ip_parts = request.remote_ip.split(".")
      ipnum = 16777216*ip_parts[0].to_i + 65536*ip_parts[1].to_i + 256*ip_parts[2].to_i + ip_parts[3].to_i 
      c_ip = CountryIp.find(:first, :conditions => ["begin_num < ? AND end_num > ?", ipnum, ipnum])
      unless c_ip.nil?
        if band_country = Country.find_by_name(c_ip.name.upcase)
          @band.country_id = band_country.id
        end
      end
      #update the states list
      @states = State.find_all_by_country_id( @band.country_id )
    end
    
  end
  
  
  # Update the specified user record. Expects the same input format as the #create action.
  def update
    unless id = get_band_id_from_request()
      return false
    end
    @band = Band.find(id)
		@request_uri = edit_band_url(id)
 		begin
			unless @band.twitter_user
				@band_twitter_authorized = false
			else
				band_client = client(true, false, @band.id)
				@twit_band = band_client.verify_credentials
				@band_twitter_authorized = true										
			end		
		rescue
				@band_twitter_authorized = false
		end					
    unless ( @band.update_attributes(params[:band]) )
      flash[:error] = "Invalid submission"
      render :action => 'edit'
      return false
    else
      respond_to do |format|
        format.html {
                      flash[:notice] = "Update successful."
                      redirect_to :action => :show
                    }
        format.js {
                    render :text => 'Update successful.'
                  }
        format.xml  { head :ok }
      end
    end
 
  end


      
  def create
    #bring in the user first and last name
    @user = User.find(session[:user_id])
		begin
			unless @band.twitter_user
				@band_twitter_authorized = false
			else
				band_client = client(true, false, @band.id)
				@twit_band = band_client.verify_credentials
				@band_twitter_authorized = true										
			end		
		rescue
				@band_twitter_authorized = false
		end					    
    @band = Band.new(params[:band])
=begin
    @band.short_name.downcase!
    @band.short_name.gsub!(/[^a-z_]/, '')
=end    
    @band.status = "active"
    if (@band.save)
      
      #make the admin associations
      @band.associations.create(:user_id => session[:user_id], :name => 'admin')
      #make the member association
      @band.associations.create(:user_id => session[:user_id], :name => 'member')
      
      #make the first set of stats
=begin        
      @band.band_statistics.create(:name => 'fans_per_day', :value => 0, :expires => 1.day.from_now)
      @band.band_statistics.create(:name => 'shares_per_day', :value => 0, :expires => 1.day.from_now)
      @band.band_statistics.create(:name => 'shares_per_fan', :value => 0, :expires => 1.day.from_now)
      @band.band_statistics.create(:name => 'capital_per_day', :value => 0, :expires => 1.day.from_now)
      @band.band_statistics.create(:name => 'capital_per_fan', :value => 0, :expires => 1.day.from_now)
      
      #now that all that business is done, update the xml file
      @band.update_playlist_xml
=end      
      flash[:notice] = 'Band created successfully.'
      
      respond_to do |format|
        # If we're in HTML mode, redirect back to the master list.
#        format.html { redirect_to :controller => :projects, :action => :new, :band_id => @band.id }
        format.html { redirect_to :action => :show, :band_id => @band.id }
        # If we're in XML mode, just return a 201 Created response.
        format.xml { head :created, :location => edit_band_url(@band) }
      end
    else
      @states = State.find_all_by_country_id( @band.country_id )
      render :action => :new
    end
    
    
    
  end
  
  def buy_stock
    @band = Band.find(params[:band_id])
    unless @band
      if params[:lightbox]
        render :text => "You've attempted to buy stock from an invalid band. Please try again.", :layout => 'lightbox'
      else
        flash[:notice] = "You've attempted to buy stock from an invalid band. Please try again."
        redirect_to (session[:last_clean_url] || '/')
      end
      return false
    end
    if @band.commerce_allowed == true    
      @available_shares = @band.available_shares_for_purchase()
      if @available_shares < @band.min_share_purchase_amount
        flash[:error] = 'There are no more shares available to purchase today. New shares are released every day at noon, so check back!'
      end
    
      @min_amount = @band.min_share_purchase_amount
      @max_amount = @band.max_share_purchase_amount > @available_shares ? @available_shares : @band.max_share_purchase_amount
    else
      flash[:error] = "This artist is not currently offering BandStock for sale. Thank you for your interest."      
    end
    render :layout => 'lightbox' if params[:lightbox]
  end
  
  
  def toggle_hidden
    unless ( (@band = Band.find(params[:id])) && (User.find(session[:user_id]).has_band_admin(@band.id)) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    if @band.status != "active"
      @band.status = "active"
    else
      @band.status = "hidden"
    end
    @band.save
    
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js
    end
    
  end
  
  
  def is_hidden
    #this action lets the user know the current bands profile is hidden
  end



  # ****************************
  # below here ajax related updates
  # ********************************


  def remote_bio_edit
    @band = Band.find(params[:id])
    
    respond_to do |format|
      format.html {
                  redirect_to :controller => 'bands', :action => 'edit', :id => @band.id
                  }
      format.js {
        
                @partial_string = render_to_string :partial => 'bands/edit_bio', :locals => {:band => @band}
                # Let the RJS render
                }
    end
  end

  
  def remote_bio_update
    @band = Band.find(params[:id])
    @band.update_attributes(params[:band])
    @band.save

    respond_to do |format|
      format.html {
                  redirect_to :controller => 'bands', :action => 'edit', :id => @band.id  
                  }
      format.js   {
                  render :partial => 'bands/bio', :locals => {:band => @band}
                  }
    end
  end

  # ***************************************
  # below here are some meta manage actions
  # ***************************************
  
  def control_panel
    unless id = get_band_id_from_request()
      redirect_to session[:last_clean_url]
      return false
    end
    
    #make sure they have proper perms
    unless ( (@user = User.find(session[:user_id])) && (@user.has_band_admin(id)) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    @band = Band.find(id)
=begin    
    #create the list vars
    @news_entries = @band.news_entries.paginate(:page => params[:news_entries_page], :order => ['updated_at DESC'], :per_page => 3)
    @concerts = @band.concerts.paginate(:page => params[:concerts_page], :order => ['created_at desc'], :per_page => 5)
    @stage_comments = @band.stage_comments.paginate(:page => params[:stage_comments_page], :order => ['created_at desc'], :per_page => 4)
    if @band.active_project
      @ledger_entries = @band.active_project.ledger_entries.paginate(:page => params["project_#{@band.active_project.id}_ledger_entries_page"], :per_page => 10)
    else
      @ledger_entries = []
    end
    @perks = @band.perks.paginate(:page => params[:perks_page], :order => ['created_at desc'], :per_page => 10)
    
    #stats
    @band_total_shares = @band.contributions.find(:all, :include => [:contribution_level]).collect {|c| c.contribution_level.number_of_shares}.sum
    @top_fans = @band.top_fans
    @new_fans_yesterday = Rails.cache.fetch("band_#{@band.id}_new_fans_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) { @band.associations.find(:all, :conditions => ['name = ? AND created_at > ? AND created_at < ?', 'fan',  1.day.ago.midnight,Time.now.midnight]).size.to_i }
    @new_shares_yesterday = Rails.cache.fetch("band_#{@band.id}_new_shares_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) { @band.contributions.find(:all, :joins => [:contribution_level], :conditions => ['contributions.created_at > ? AND contributions.created_at < ?', 1.day.ago.midnight, Time.now.midnight]).collect{|c| c.contribution_level.number_of_shares}.sum }
=end    
  end
  
=begin    
  def manage_fans
    unless id = get_band_id_from_request()
      return false
    end
    
    unless ( @band = Band.find_by_id(id) ) && ( User.find(session[:user_id]).has_band_admin(@band.id) )
      redirect_to session[:last_clean_url]
    end
  
    @new_investors_yesterday = Rails.cache.fetch("band_#{@band.id}_new_fans_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) {
       all = @band.contributions.find(:all, :joins => :user, :conditions => ['contributions.created_at > ? AND contributions.created_at < ?',  1.day.ago.midnight,Time.now.midnight])
       previous = @band.contributions.find(:all, :joins => :user, :conditions => ['contributions.created_at < ?',  1.day.ago.midnight]) 
       (all-previous).size.to_i
       }
    @new_investments_yesterday = Rails.cache.fetch("band_#{@band.id}_new_shares_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) { @band.contributions.find(:all, :joins => [:contribution_level], :conditions => ['contributions.created_at > ? AND contributions.created_at < ?', 1.day.ago.midnight, Time.now.midnight]).collect{|c| c.contribution_level.number_of_shares}.sum }
    
    #do the update band statistics loop
    Rails.cache.fetch("last_statistics_update_for_band_#{@band.id}", :expires_in => (Time.now.end_of_day+1.second - Time.now) ) { update_band_statistics(@band.id) }
   
    @zipcode_passed = params[:zipcode]
    if params[:zipcode] == 'Zip Code'
      zip = nil
    else
      zip = params[:zipcode]
    end

    if ( ( @zip = Zipcode.find_by_zipcode(zip) ) && ( @miles_away_passed = params[:miles_away].to_f ) )
      miles_away = params[:miles_away].to_f
      #1.8 used as fudge factor -- yeah I know this isn't accurate, but honestly no body lives in the center of their zip code anyway so what are we supposed to do without better address resolution
      lat_lower = @zip.latitude.to_f-(miles_away/(1.8*MILES_PER_DEGREE))
      lat_upper = @zip.latitude.to_f+(miles_away/(1.8*MILES_PER_DEGREE))
      longi_lower = @zip.longitude.to_f-(miles_away/(1.8*MILES_PER_DEGREE))
      longi_upper = @zip.longitude.to_f+(miles_away/(1.8*MILES_PER_DEGREE))
      zipcodes = Zipcode.find(:all, :conditions => ['latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?',lat_lower,lat_upper,longi_lower,longi_upper]).collect{|z| z.zipcode}
    end
    
    if ((@invest_low_passed = params[:invest_low]) && params[:invest_low ] != '')
      investment_lower = params[:invest_low].to_f
    else
      investment_lower = 0
    end
    if ((@invest_high_passed = params[:invest_high]) && params[:invest_high] != '')
      investment_upper = params[:invest_high].to_f
    else
      investment_upper = 10000000000
    end
    
    amounts_available_boolean = ((params[:invest_low] && (params[:invest_low] != '')) || (params[:invest_high] && (params[:invest_high] != '')))
    #now actually make the fans object
    #assume we'll get results
    @fans_empty = false
    if (zipcodes && !zipcodes.empty?) && amounts_available_boolean
      #RAILS_DEFAULT_LOGGER.warn('\nin all\n')
      fans_by_zip = User.find_all_by_zipcode(zipcodes)
      #RAILS_DEFAULT_LOGGER.warn('\nFBZ ')
      #RAILS_DEFAULT_LOGGER.warn(fans_by_zip)
      contribs = @band.contributors
      for contrib in contribs
        contrib[:amount_given] = contrib.contributions_made_to_band(@band.id).collect{|c| c.contribution_level.us_dollar_amount}.sum
      end
      #RAILS_DEFAULT_LOGGER.warn('\nCONTRIBS11 ')
      #RAILS_DEFAULT_LOGGER.warn(contribs)
      contribs.reject! { |c| c[:amount_given] < investment_lower || c[:amount_given] > investment_upper }
      #RAILS_DEFAULT_LOGGER.warn('\nCONTRIBS22 ')
      #RAILS_DEFAULT_LOGGER.warn(contribs)
      @fans = (fans_by_zip & contribs)
    elsif (zipcodes && !zipcodes.empty?)
      #RAILS_DEFAULT_LOGGER.warn('\nonly zips\n')
      @fans = @band.contributors.find_all_by_zipcode(zipcodes)
    elsif amounts_available_boolean
      #RAILS_DEFAULT_LOGGER.warn('\nonly amounts\n')
      #do the work!
      contribs = @band.contributors
      for contrib in contribs
        contrib[:amount_given] = contrib.contributions_made_to_band(@band.id).collect{|c| c.contribution_level.us_dollar_amount}.sum
      end
      contribs.reject! { |c| c[:amount_given] < investment_lower || c[:amount_given] > investment_upper }
      @fans = contribs
    else
      @fans = @band.contributors.find(:all, :limit => 50, :offset => rand(@band.contributors.count))
      @fans_empty = true
    end
    
    
    
    respond_to do |format|
      format.html {
                    @top_fans = @band.top_fans
    
                    @total_shares = @band.contributions.find(:all, :include => :contribution_level).collect{|a| a.contribution_level.number_of_shares}.sum()
                    @total_capital = @band.contributions.find(:all, :include => :contribution_level).collect{|a| a.contribution_level.us_dollar_amount}.sum()
                    
                    #these both assign to 0 if no records return
                    @investors_yesterday = Rails.cache.fetch("band_#{@band.id}_investors_yesterday", :expires_in => (Time.now.end_of_day - Time.now)) { @band.contributors.find(:all, :conditions => ["contributions.created_at > ?", 1.day.ago], :group => "id").length }
                    @new_investments = Rails.cache.fetch("band_#{@band.id}_investments_yesterday", :expires_in => (Time.now.end_of_day - Time.now)) {@band.contributions.find(:all, :conditions => ["created_at > ?", 1.day.ago]).collect{|i| i.contribution_level.us_dollar_amount}.sum.to_i}
                  }
      format.js
      format.xml
    end
  
  end


  def manage_perks
    unless id = get_band_id_from_request()
      return false
    end
    
    @band = Band.find(id)
    
    @perks = @band.perks.paginate(:page => params[:perks_page], :per_page => 13, :order => ['created_at desc'])
    @contribution_levels = @band.contribution_levels.paginate(:page => params[:contribution_levels_page], :per_page => 13, :order => ['created_at desc'])
    @earned_perks = EarnedPerk.paginate(:page => params[:earned_perks_page], :per_page => 13, :conditions => ['band_id = ?', id], :order => ['earned_perks.filled, earned_perks.created_at desc'], :limit => 10)
    
    #create the new quick-add templates
    @fresh_contribution_level = ContributionLevel.new
    @fresh_contribution_level.band_id = @band.id
    
    @fresh_perk = Perk.new
    @fresh_perk.band_id = @band.id
   
  end

  
  def manage_project
    unless id = get_band_id_from_request()
      return false
    end
    
    @band = Band.find(id, :include => :projects, :order => 'projects.active, projects.created_at desc')
    
    @fresh_ledger_entry = LedgerEntry.new
  end


  def manage_photos
    unless id = get_band_id_from_request()
      return false
    end

    @band = Band.find(id)
    @photos = @band.photos.paginate(:page => params[:thumbnail_photos_page], :conditions => ["thumbnail is null"], :order => ['created_at DESC'], :per_page => 6)
    @photo_albums = @band.photo_albums.paginate(:page => params[:photo_albums_page], :order => ['created_at DESC'], :per_page => 10)
   
    @photos_uploaded = Photo.find_all_by_band_id(@band.id).size
    @photo_albums_created = @photo_albums.size
    @megabytes_available = '??'
    
    #create quick add fresh objects
    @fresh_photo = Photo.new(:band_id => @band.id)
    @fresh_photo_album = PhotoAlbum.new(:band_id => @band.id)
    
  end
  
  
  def manage_music
    unless id = get_band_id_from_request()
      return false
    end

    @band = Band.find(id)
    @songs = @band.songs.paginate(:page => params[:songs_page], :order => ['created_at DESC'], :per_page => 10)
    @music_albums = @band.music_albums.paginate(:page => params[:music_albums_page], :order => ['created_at DESC'], :per_page => 10)
    
    @music_albums_created = @music_albums.size
    @tracks_uploaded = Song.find_all_by_band_id(@band.id).size
    @megabytes_available = '??'
    
    #create quick add fresh objects
    @fresh_song = Song.new(:band_id => @band.id)
    @fresh_music_album = MusicAlbum.new(:band_id => @band.id)
    
  end
=end  
  def manage_users
    unless id = get_band_id_from_request()
      return false
    end
    @band = Band.find(id)
    
    @associations = @band.associations.all.paginate(:page => params[:associations_page], :order => ['name ASC'], :per_page => 20, :conditions => ['name != ?', 'watching'])

    @fresh_association = Association.new(:band_id => @band.id)
    
    @number_of_admins = @band.associations.find(:all, :conditions => ['name = ?', 'admin']).size
    @number_of_members = @band.associations.find(:all, :conditions => ['name = ?', 'member']).size
    
    
  end
  
  
  
  
  
protected
  
  
  ######################
  # update statistics routine
  ######################
  
  
  
  
=begin  
  def update_band_statistics(band_id)
    if band = Band.find_by_id(band_id)
      
      #fans per day  
      s = band.band_statistics.find_by_name('fans_per_day', :order => "created_at desc")
      if s.nil? || s.expires < Time.now
        for n in 1..(((Time.now - s.expires)/86400).to_i-1)
          ns = BandStatistic.new(:name => 'fans_per_day', :band_id => band.id)
        
          divisor = (((s.expires+n.days) - band.created_at)/86400) #where 86400 is seconds in a day
          if divisor == 0 then divisor = 1 end
          ns.value = Band.find(band.id).contributors.size / divisor 
          ns.expires = (s.expires+n.days).end_of_day
          ns.save
      
          #calculate total shares for the following two stats
          tot_shares = band.contributions.find(:all, :conditions => ['created_at < ?', (s.expires+n.days).midnight]).collect{|c| c.contribution_level.number_of_shares}.sum
      
          #shares per day
          #s = band.band_statistics.find_by_name('shares_per_day', :order => "created_at desc")
        
          ns = BandStatistic.new(:name => 'shares_per_day', :band_id => band.id)
        
          divisor = (((s.expires+n.days) - band.created_at)/86400) #where 86400 is seconds in a day
          if divisor == 0 then divisor = 1 end
          ns.value = tot_shares / divisor 
          ns.expires = (s.expires+n.days).end_of_day
          ns.save
      
          #shares per fan
          #s = band.band_statistics.find_by_name('shares_per_fan', :order => "created_at desc")
        
          ns = BandStatistic.new(:name => 'shares_per_fan', :band_id => band.id)
        
          divisor =  Band.find(band.id).contributors.size
          if divisor == 0 then divisor = 1 end
          ns.value = tot_shares / divisor
          ns.expires = (s.expires+n.days).end_of_day
          ns.save
      
          #capital per day
          #s = band.band_statistics.find_by_name('capital_per_day', :order => "created_at desc")
        
          ns = BandStatistic.new(:name => 'capital_per_day', :band_id => band.id)
        
          divisor = (((s.expires+n.days) - band.created_at)/86400) #where 86400 is seconds in a day
          if divisor == 0 then divisor = 1 end
          ns.value = band.contributions.find(:all, :conditions => ['created_at < ?', (s.expires+n.days).midnight]).collect{|c| c.contribution_level.us_dollar_amount}.sum / divisor
          ns.expires = (s.expires+n.days).end_of_day
          ns.save
      
          #capital per fan
          #s = band.band_statistics.find_by_name('capital_per_fan', :order => "created_at desc")
      
          ns = BandStatistic.new(:name => 'capital_per_fan', :band_id => band.id)
        
          divisor = Band.find(band.id).contributors.size
          if divisor == 0 then divisor = 1 end
          ns.value = band.contributions.find(:all, :conditions => ['created_at < ?', (s.expires+n.days).midnight]).collect{|c| c.contribution_level.us_dollar_amount}.sum / divisor
          ns.expires = (s.expires+n.days).end_of_day
          ns.save
          
        #end the for
        end
      #end the big if
      end
    end
    
    return Time.now
  end

=end
private

	def convert_twitter_name(name)	
		unless (name)
      redirect_to session[:last_clean_url]      
      return false
    end	

		# Parameters
  	apiurl = 'http://api.twitter.com/1/users/show.xml'
		url = URI.parse(apiurl)
		res = Net::HTTP.new(url.host, url.port)

		# Form GET Request
		req, res = res.get(url.path+'?'+'screen_name='+name)

		doc = Document.new(res)

		@twitter_id = XPath.first( doc, '//id') { |e| puts e.text }
		
		if @twitter_id.count == 1
			@protected = XPath.first( doc, '//protected') { |e| puts e.text }
			for p in @protected
				p = p.to_s
			end
			@protected = p.to_s			

		
			for i in @twitter_id
				i = i.to_s
			end
			@twitter_id = i.to_s		
			
			obj = Array.new([@twitter_id, @protected])
			
			return obj
		else
			return false
		end
	end


end
