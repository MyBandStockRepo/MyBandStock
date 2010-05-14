class BandsController < ApplicationController
  
 protect_from_forgery :only => [:create, :update]
 before_filter :only => :post, :only => [:create, :update] 
 before_filter :authenticated?, :except => [:show]
# skip_filter :update_last_location, :except => [:index, :show, :control_panel, :manage_users, :manage_project, :manage_music, :manage_photos, :manage_perks, :manage_fans, :inbox]
 skip_filter :update_last_location, :except => [:index, :show, :control_panel, :manage_users]
  
  def index
    redirect_to session[:last_clean_url]
  end
  
  def show
    id = get_band_id_from_request()
    @band = Band.find(id, :include => [:concerts, :news_entries, :stage_comments])
    
    #make sure the band isn't hidden
    if @band.status != "active"
      render :action => 'is_hidden'
    end
    
    #create the list vars
=begin
    @news_entries = @band.news_entries.paginate(:page => params[:news_entries_page], :order => ['updated_at DESC'], :per_page => 3)
    @concerts = @band.concerts.paginate(:page => params[:concerts_page], :order => ['date DESC'], :per_page => 5)
    @stage_comments = @band.stage_comments.paginate(:page => params[:stage_comments_page], :order => ['created_at desc'], :per_page => 4)
    if @band.active_project
      @ledger_entries = @band.active_project.ledger_entries.paginate(:page => params["project_#{@band.active_project.id}_ledger_entries_page"], :per_page => 10)
    else
      @ledger_entries = []
    end
    @perks = @band.perks.paginate(:joins => :contribution_levels, :conditions => {:perks => {:contribution_levels =>{:disabled => false, :locked => true}}}, :page => params[:perks_page], :order => ['created_at desc'], :per_page => 10)
    

    @band_fans = @band.contributors.size
    @band_total_shares = @band.contributions.collect{|c| c.contribution_level.number_of_shares}.sum
    
    @user_can_buy_stock = Band.find_by_id(id, :joins => [:contribution_levels, :projects], :conditions => {:band => {:contribution_levels => {:disabled => false}, :projects => {:active => true} } } )
    
    @top_fans = @band.top_fans
    
    @new_fans_yesterday = Rails.cache.fetch("band_#{@band.id}_new_fans_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) { @band.associations.find(:all, :conditions => ['name = ? AND created_at > ? AND created_at < ?', 'fan',  1.day.ago.midnight,Time.now.midnight]).size.to_i }
    @new_shares_yesterday = Rails.cache.fetch("band_#{@band.id}_new_shares_yesterday", :expires_in => (1.days.from_now.midnight-Time.now) ) { @band.contributions.find(:all, :joins => [:contribution_level], :conditions => ['contributions.created_at > ? AND contributions.created_at < ?', 1.day.ago.midnight, Time.now.midnight]).collect{|c| c.contribution_level.number_of_shares}.sum }
    
    @fresh_stage_comment = StageComment.new(:band_id => @band.id)
=end
  end
  
  
  def edit
    unless id = get_band_id_from_request()
      return false
    end
    
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

    unless ( @band.update_attributes(params[:band]) )
      render :action => 'edit'
      return false
    else
    
      respond_to do |format|
        format.html { 
                      flash[:notice] = "Update successful."
                      redirect_to :action => :edit
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
    
    unless ( @application = @user.band_applications.find_by_approved_and_created(true, false) )
      redirect_to session[:last_clean_url]
      return false
    end
    
    @band = Band.new(params[:band])
=begin
    @band.short_name.downcase!
    @band.short_name.gsub!(/[^a-z_]/, '')
=end    
    @band.status = "active"
    if (@band.save)
      
      #kill their app
=begin
      @application.created = true
      @application.save
=end    
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
      flash[:notice] = 'Band created successfully.  Please now submit your first project application.'
      
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

=begin
  def update_headline_photo
    photo_id = params[:id].split("_")[1]
    @photo = Photo.find_by_id(photo_id)
    unless (!@photo.nil?) && User.find(session[:user_id]).has_band_admin(@photo.band.id)
      flash[:notice] = 'Bad drag-drop or bad perms.'
    end
    #else
    
    @photo.band.headline_photo_id = @photo.id
    @photo.band.save
    
    respond_to do |format|
      format.html {
                    flash[:notice] = 'Headline photo updated successfully.'
                    redirect_to session[:last_clean_url]
                  }
      format.js   # Let the RJS render
      format.xml  { head :ok }
    end
  
  end
  
  def update_playlist_position
    song_id = params[:id].split("-")[1].to_i
    unless ( ( @song = Song.find_by_id(song_id) ) && ( User.find(session[:user_id]).has_band_admin(@song.band.id) ) && ( @position = params[:position].to_i ) )
      flash[:notice] = 'Bad drag-drop or bad perms.'
      redirect_to session[:last_clean_url]
      return false
    end
    
    @playlist_songs = @song.band.songs.find(:all, :conditions => ['playlist_position is NOT NULL'], :order => 'playlist_position ASC')
    #auto-shift their position up if everything above is blank
    if @playlist_songs.empty?
      @position = 0
    elsif (@playlist_songs.last.playlist_position < @position)
      if @playlist_songs.last == @song
        #do nothing, we're done here
        render :nothing => true
        return true
      else
        @position = @playlist_songs.last.playlist_position+1
      end
    end
      
    if @old_song = Song.find(:first, :conditions => ['band_id = ? AND playlist_position = ?', @song.band.id, @position])
      @old_song.playlist_position = nil
      @old_song.save
    end
    
    @song.playlist_position = @position
    @song.save
    
    @playlist_songs = @song.band.songs.find(:all, :conditions => ['playlist_position is NOT NULL'], :order => 'playlist_position ASC')
    #make sure they didn't move out a song
    @playlist_songs.each_with_index do |song, index|
      if @position = song.playlist_position
        @position = index
      end
      song.playlist_position = index
      song.save
    end
    
    #now that all that business is done, update the xml file
    @song.band.update_playlist_xml
    
    #and finally render
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    
  end
  
  def clear_playlist_slot
    unless User.find(session[:user_id]).has_band_admin(params[:band_id])
      flash[:notice] = 'You don\'t have proper permissions to edit this bands playlist.'
      redirect_to session[:last_clean_url]
      return false
    end
    
    song = Song.find_by_band_id_and_playlist_position(params[:band_id], params[:id])
    unless song
      flash[:notice] = 'Band position, already nil.'
      redirect_to session[:last_clean_url]
      return false
    else
      song.playlist_position = nil;
      song.save
    end
    
    @playlist_songs = song.band.songs.find(:all, :conditions => ['playlist_position is NOT NULL'], :order => 'playlist_position ASC')
    
    #re-index the rest of em
    @playlist_songs.each_with_index do |song, index|
      song.playlist_position = index
      song.save
    end
    
    #now that all that business is done, update the xml file
    song.band.update_playlist_xml
    
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js
      format.xml
    end
    
  end
    


  # ***************************************
  # below here are checkout related actions
  # ***************************************
  
  def select_contribution_level
    @band = Band.find_by_id(params[:id], :joins => [:projects, :contribution_levels], :conditions => {:projects => {:active => true}})
    unless @band #they guessed a band that doesn't have any contrib_levels yet, send_em
      flash[:notice] = "You've attempted to buy stock from a band that hasn't setup any contribution levels yet.  Please let them know they need to do this."
      redirect_to (session[:last_clean_url] || '/')
      return false
    end
    @active_contribution_levels = @band.contribution_levels.find(:all, :conditions => {:disabled => false}, :order => 'us_dollar_amount DESC')
    if ( (@agreement = params[:agreement]) && (@security = params[:security]) )
      if @agreement == '1'
        @agreement = true
      else
        @agreement = false
      end
      if @security == '1'
        @security = true
      else
        @security = false
      end
      unless ( @security && @agreement )
        @requires_acceptance = true
      end
    end
    
    
  end
  
  def buy_stock
  
    #make sure the c_level is good
    contribution_level = nil
    unless contribution_level = ContributionLevel.find_by_id(params[:contribution_level], :include => :perks)
      redirect_to session[:last_clean_url]
    end
    
    unless ( (params[:agreement] == '1') && (params[:security] == '1') )
      redirect_to :controller => 'bands', :action => 'select_contribution_level', :id => contribution_level.band_id, :agreement => params[:agreement], :security => params[:security]
      return false
    end
    
    #begin the transaction
    @frontend = Google4R::Checkout::Frontend.new(GOOGLE_CHECKOUT_CONFIGURATION)
    @frontend.tax_table_factory = TaxTableFactory.new
    checkout_command = @frontend.create_checkout_command
    
    #get the project_id for the band
    project_id = contribution_level.band.active_project.id
    # Adding an item to shopping cart
    checkout_command.shopping_cart.create_item do |item|      
      item.name = "#{contribution_level.number_of_shares} shares in #{contribution_level.band.name}"
      item.description = "#{contribution_level.number_of_shares} shares in #{contribution_level.band.name}"
      item.unit_price = Money.new(contribution_level.us_dollar_amount*100, "USD") #this takes cents
      item.quantity = 1
      item.id = "cl-#{contribution_level.id}-#{session[:user_id]}-#{project_id}"
    end
    
    #add the perks
    for perk in contribution_level.perks
      checkout_command.shopping_cart.create_item do |item|      
        item.name = "#{perk.name}"
        item.description = "#{perk.description}"
        item.unit_price = Money.new(0, "USD")
        item.quantity = 1
        item.id = "p-#{perk.id}"
      end
    end
    
    # Create a flat rate shipping method for lower 48
    checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
      shipping_method.name = "Free to Continental-US"
      shipping_method.price = Money.new(0, "USD")
      # Restrict shipping to US-48
      shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
        area.area = Google4R::Checkout::UsCountryArea::CONTINENTAL_48
      end
    end
    
    # Create a flat rate shipping method for HI and AL
    checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|
      shipping_method.name = "HI+AL Flat Rate"
      shipping_method.price = Money.new(8, "USD")
      # Restrict shipping to HI+AL
      shipping_method.create_allowed_area(Google4R::Checkout::UsStateArea) do |area|
        area.state = 'HI'
      end
      shipping_method.create_allowed_area(Google4R::Checkout::UsStateArea) do |area|
        area.state = 'AL'
      end
    end
    
    checkout_command.continue_shopping_url = "#{SITE_URL}/me/purchases"
    response = checkout_command.send_to_google_checkout    
    redirect_to response.redirect_url    
  end
  
  
  
  
  # ************************
  # Mailbox code!
  # ************************
  
  def inbox
    
    unless id = get_band_id_from_request()
      return false
    end
    unless ( @band = Band.find_by_id(id) ) && ( User.find(session[:user_id]).is_member_of_band(@band.id) )
      redirect_to session[:last_clean_url]
    end
    @bodytag_id= "mail"
    @fresh_band_mail = BandMail.new(:band_id => @band.id, :from_band => true)
    
    if @message = BandMail.find_by_id(params[:message_id])
      @messages_in_thread = @band.band_mail.paginate(:page => params["message_#{params[:message_id]}_messages"], :order => ['created_at desc'], :conditions => ['created_at < ? AND user_id = ?', message.created_at, message.user_id])
    else
      @messages_in_thread = nil
    end

    
    @band_mail = @band.band_mails.paginate(:conditions => ['band_hidden = 0'], :page => params[:band_mails_page], :per_page => 15, :order => 'created_at DESC' )
    
    if @user = User.find_by_nickname(params[:nickname])
      @passed_user_nickname = @user.nickname
    end
    
    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    
  end
  
  
  def auto_complete_for_recipient_nickname
    unless ( (params[:recipient] && (nick_search = params[:recipient][:nickname]) ) && (nick_search.length >= 2) )
      render :nothing => true
      return false
    end
    
    @users = User.find(:all, :conditions => ['nickname LIKE ?', "%#{nick_search}%"], :limit => 15)

    respond_to do |format|
      format.html {
                    render :nothing => true
                  }
      format.js   {
                    #dont like calling render in the code but it is what it is
                    render :partial => 'band_mails/user_recipient_autocomplete', :locals => {:user_collection => @users}
                  }
    end
    
  end
  
  # END MAILBOX CODE
  
=end  
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
    
    @associations = @band.associations.paginate(:page => params[:associations_page], :order => ['name ASC'], :per_page => 20, :conditions => ['name != ?', 'watching'])

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



end
