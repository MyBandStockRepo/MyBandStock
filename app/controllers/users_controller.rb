class UsersController < ApplicationController

 protect_from_forgery :only => [:create, :update]
 before_filter :authenticated?, :except => [:new, :create, :state_select]
						# skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists, :manage_friends, :inbox, :purchases]
 skip_filter :update_last_location, :except => [:show, :edit, :membership, :control_panel, :manage_artists]

  
  def index
    #What do we do with this action?
    redirect_to session[:last_clean_url]
  end
  
  
  def show
    unless (@user = User.find(params[:id]))
      redirect_to session[:last_clean_url]
      return false
    end
=begin    
    @top_friends = @user.top_friends
    @top_invested_artists = @user.top_invested_artists
    
=end    
    @random_band = get_random_band()


    respond_to do |format|
      format.html
      format.js
      format.xml
    end
    
  end
  
  
  def edit
    unless (id = params[:id])
      id = session[:user_id]
    else
      unless ( (id != session[:user_id]) && (User.find(session[:user_id]).site_admin) )
        id = session[:user_id]
      end
    end
    
    @user = User.find(id)
    
    @random_band = get_random_band()
    
    unless @user.country_id.nil?
      @states = State.find_all_by_country_id(@user.country_id)
    else
      @states = nil
    end
  
  end
  
  
  # Update the specified user record. Expects the same input format as the #create action.
  def update
    unless ( (id = params[:id]) && ( (id == session[:user_id]) || (User.find(session[:user_id]).site_admin) ) )
      id = session[:user_id]
    end
    @user = User.find(id)
    
    @random_band = get_random_band()
    
    #for the regular "post"ers make sure the country matches the state in case they changed it
    unless ( params[:user][:country_id].nil? || (params[:user][:country_id].to_i == @user.country_id) || (params[:user][:state_id] == '1') )
      unless Country.find(params[:user][:country_id]).states.collect{|s| s.id}.include?(params[:user][:state_id].to_i)
      #if the state isn't in the country then reset the state_id update and redirect
      params[:user][:state_id] = 1
      @user.update_attributes(params[:user])
      @user.save
      redirect_to :action => "state_select"
      return true
      end
    end

    
    if params[:user][:phone]
      params[:user][:phone].gsub!(/[^0-9]/, '')#clean phone
    end
    @user.update_attributes(params[:user])
    
    success = @user.save
=begin    
    photo_success = true #init this
    #if there is a new user photo update it
    if (success && (params[:user_photo] && (params[:user_photo][:uploaded_data] != '')) )
      @user_photo = UserPhoto.new(params[:user_photo])
      @user_photo.user_id = session[:user_id]
      photo_success = @user_photo.save
      if photo_success
        #update the perms on all parent directories
        File.chmod( 0755, File.dirname(RAILS_ROOT+'/public'+@user_photo.public_filename(:center_graphic)) )
        File.chmod( 0755, File.dirname(RAILS_ROOT+'/public'+@user_photo.public_filename(:center_graphic))+'/../' )
        
        #and see if we need to delete an old one
        if (old = UserPhoto.find_by_id(@user.headline_photo_id))
          old.destroy
        end
        
        #then update the user record to use that image
        @user.headline_photo_id = @user_photo.id
        @user.save
      end
    end
=end    
    
    respond_to do |format|
      format.html { 
                    unless success && photo_success
                      render :action => 'edit'
                      return false
                    else
                      flash[:notice] = "Profile updated."
                      redirect_to session[:last_clean_url]
                    end
                  }
      format.js
      format.xml  { head :ok }
    end

  end


  def new
    @user = User.new
    #check to see if they've been around before
    if params[:user]
      @user = User.new(params[:user])
    end
   
    if (@user.country_id.nil? || @user.country_id == '' )
      #calculate their ip number to determine country of origin
      ip_parts = request.remote_ip.split(".")
      ipnum = 16777216*ip_parts[0].to_i + 65536*ip_parts[1].to_i + 256*ip_parts[2].to_i + ip_parts[3].to_i 
      c_ip = CountryIp.find(:first, :conditions => ["begin_num < ? AND end_num > ?", ipnum, ipnum])
      unless c_ip.nil?
        if user_country = Country.find_by_name(c_ip.name.upcase)
          @user.country_id = user_country.id
        end
      end
      #update the states list
      state_select(@user.country_id)
    end

  end
      
  
  def state_select(passed_country_id = nil)
    c_id = nil
    if passed_country_id
      c_id = passed_country_id
    elsif (params[:user] && params[:user][:country_id])
      @user_search = User.new(params[:user])
      c_id = params[:user][:country_id]
    elsif params[:country_id]
      c_id = params[:country_id]
    elsif session[:user_registration_info] && session[:user_registration_info][:country_id]
      @user_search = User.new(session[:user_registration_info])
      c_id = session[:user_registration_info][:country_id]
    elsif (@user_search = User.find_by_id(session[:user_id]))
      c_id = @user_search.country_id
    end

    @states = State.find_all_by_country_id( c_id )
  end
  
  
  def create
=begin
    #validate the captcha
    if ((session[:passed_captcha] && params[:captcha_response]) || (session[:passed_captcha] != true) )
      unless captcha_valid?(params[:captcha_response])
        @captcha_error = 'You did not enter the correct letters and numbers in the captcha at the bottom.  Please try again.'
        @user = User.new
        #check to see if they've been around before
        if params[:user]
          @user = User.new(params[:user])
          @user.valid?
        end
        state_select(@user.country_id)
        render :action => 'new'
        return false
      end
    end
=end
    
    #check to see if they've posted
    if params[:user]
      #so they have posted to us, filter the posted data
      session[:user_registration_info] = params[:user]
      user_registration_info = params[:user]
    elsif session[:user_registration_info] #check to see if they've got goodies in session
      user_registration_info = session[:user_registration_info]
    else
      #they don't have session data and they haven't posted to us so get em out of here
      flash[:notice] = "Something went wrong, please try registering again."
      redirect_to :action => "new"
    end

    # Hash the password before putting it into DB
    user_registration_info[:password] = Digest::SHA2.hexdigest(user_registration_info[:password])
    # We must also hash the confirmation entry so the model can check them together
    user_registration_info[:password_confirmation] = Digest::SHA2.hexdigest(user_registration_info[:password_confirmation])
   
    #we can assume at this point that we've got something ready to authenticate in user_registration_info
    @user = User.new(user_registration_info)

    if (@user.save)
      #clear out the session
      session[:user_registration_info] = nil
      session[:user_id] = @user.id
      flash[:notice] = "Registration successful."
      session[:auth_success] = true
      UserNotifier.registration_notification(@user).deliver
      #if @user.state_id == -1 
      #  redirect_to :action => :state_select
      #  return
      #else
        redirect_to (session[:last_clean_url] || ('/fan_home'))
        return
      #end
      
    else
      state_select(@user.country_id)
      @user.password = ''
      @user.password_confirmation = ''
      render :action => :new
      return
    end
    
    respond_to do |format|
      # If we're in HTML mode, redirect back to the master list.
      format.html { redirect_to edit_user_url(@user) }
      # If we're in XML mode, just return a 201 Created response.
      format.xml { head :created, :location => user_path(@user) }
    end
  end
  
  
  def membership
  #this action shows all the bands a user is a part of
    @user = User.find(params[:id])
    @user_bands = Band.find( @user.associations.find_all_by_name('member').collect {|a| a.band_id} )
  end
  
  
  def toggle_band_watching
    unless @assoc = Association.find_by_user_id_and_band_id_and_name(session[:user_id], params[:id], 'watching')
      #create the association
      if band = Band.find_by_id(params[:id])
        Association.new do |a|
          a.user_id = session[:user_id]
          a.band_id = params[:id]
          a.name = 'watching'
          a.save
        end
      end
    else
      #destroy the existing association
      @assoc.destroy
    end
        
        
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js   {
                    unless params[:remove_div]
                      url_hash = {:controller => 'users', :action => 'toggle_band_watching', :id => params[:id]}
                      unless @assoc #unless the association was just destroyed
                        render :inline => "=link_to_remote '<strong>Remove</strong>', {:update => 'add', :url =>  url_hash }, {:class => 'remove', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                      else #if it was just destroyed
                        render :inline => "=link_to_remote '<strong>Watch</strong>', {:update => 'add', :url => url_hash }, {:class => 'add', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                      end
                      return true
                    else
                      #let the rjs render
                    end
                  }
                 
    end
    
  end
=begin  
  
  def add_user_friend
    unless assoc = UserFriend.find_by_source_user_id_and_destination_user_id(session[:user_id], params[:id])
      #create the association
      UserFriend.new do |u|
        u.source_user_id = session[:user_id]
        u.destination_user_id = params[:id]
        u.save
      end
    else
      flash[:notice] = 'You\'ve already added this person as your friend!'
      redirect_to session[:last_clean_url]
      return false
    end
        
        
    respond_to do |format|
      format.html {
                    flash[:notice] = 'Friend added.'
                    redirect_to session[:last_clean_url]
                  }
      format.js   {
                    url_hash = {:controller => 'users', :action => 'remove_user_friend', :id => params[:id]}
                    render :inline => "=link_to_remote '<strong>Unfriend</strong>', {:update => 'friend', :url =>  url_hash }, {:class => 'remove', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                  }                 
    end
    
  end
  
  
  def remove_user_friend
    unless ( (@source_assoc = UserFriend.find_by_source_user_id_and_destination_user_id(session[:user_id], params[:id])) || (@dest_assoc = UserFriend.find_by_destination_user_id_and_source_user_id(session[:user_id], params[:id])) )
      flash[:notice] = 'There isn\'t a friendship to delete'
      redirect_to session[:last_clean_url]
      return false
    end  
    #else
    
    #this is dirty but I'm assigning again    
    @source_assoc = UserFriend.find_by_source_user_id_and_destination_user_id(session[:user_id], params[:id])
    @dest_assoc = UserFriend.find_by_destination_user_id_and_source_user_id(session[:user_id], params[:id])
    
    @source_assoc.destroy if @source_assoc
    @dest_assoc.destroy if @dest_assoc
    
    respond_to do |format|
      format.html {
                    flash[:notice] = 'Friend removed.'
                    redirect_to session[:last_clean_url]
                  }
      format.js   {
                    url_hash = url_hash = {:controller => 'users', :action => 'add_user_friend', :id => params[:id]}
                    render :inline => "=link_to_remote '<strong>Friend</strong>', {:update => 'friend', :url => url_hash }, {:class => 'add', :href => url_for(url_hash)}", :type => :haml, :locals => {:url_hash => url_hash}
                  }
                 
    end
    
  end
  
  
  def blank_headline_photo
    @user = User.find(session[:user_id])
    if (p = @user.user_photos.first)
      p.destroy
    end
    
    @user.headline_photo_id = nil
    @user.save
    
    respond_to do |format|
      format.html {
                    redirect_to session[:last_clean_url]
                  }
      format.js
      format.xml
    end
    
  end
  #************************
  #  USER Control Panel STUFF
  #************************


  def inbox
    unless @user = User.find_by_id(session[:user_id])
      redirect_to session[:last_clean_url]
    end
    
    @bodytag_id= "mail" #from dan for view stuff
    
    @random_band = get_random_band()
    
    @fresh_band_mail = BandMail.new(:user_id => @user.id, :from_band => false)
    
    if @message = BandMail.find_by_id(params[:message_id])
      @messages_in_thread = @user.band_mail.paginate(:page => params["message_#{params[:message_id]}_messages"], :order => ['created_at desc'], :conditions => ['created_at < ? AND band_id = ?', message.created_at, message.band_id])
    else
      @messages_in_thread = nil
    end
    
    @band_mail = @user.band_mails.paginate(:conditions => ['user_hidden = 0'], :page => params[:band_mails_page], :per_page => 15, :order => 'created_at DESC' )
    
    if (@band_name = params[:band_name])
      @band_name.strip!
    end
    
    respond_to do |format|
      format.html
    end
    
  end
  
  
  def auto_complete_for_recipient_band_name
    unless ( (params[:recipient] && (band_name_search = params[:recipient][:band_name]) ) && (band_name_search.length >= 2) )
      render :nothing => true
      return false
    end
    
    @bands = Band.find(:all, :conditions => ['name LIKE ?', "%#{band_name_search}%"], :limit => 15)

    respond_to do |format|
      format.html {
                    render :nothing => true
                  }
      format.js   {
                    #dont like calling render in the code but it is what it is
                    render :partial => 'band_mails/band_recipient_autocomplete', :locals => {:band_collection => @bands}
                  }
    end
    
  end
  
=end  
  def control_panel
    @user = User.find(session[:user_id])
    
    @top_friends = @user.top_friends
    @top_invested_artists = @user.top_invested_artists
    
#    @waiting_friends = (UserFriend.find(:all, :conditions => ['destination_user_id = ?', @user.id]).collect{|uf| uf.source} - @user.user_friends.collect{|u| u.destination})
	#rails 3
	@waiting_friends = (UserFriend.where(['destination_user_id = ?', @user.id]).collect{|uf| uf.source} - @user.user_friends.collect{|u| u.destination})

    @random_band = get_random_band()
    
  end  
  
=begin  
  def manage_artists
    unless ( @user = User.find_by_id(session[:user_id], :joins => {:earned_perks => {:google_checkout_order => :contributions}}) )
      @user = User.find(session[:user_id]) #the above is done for bringing data out with inner joins for better performance.  Although since I use joins, when a user cant fill one of those join models it returns nil.  so we have to be careful.
    end
    
    @total_shares = @user.total_shares
    @total_friends = @user.friends.size
    @user_net_worth = @user.net_worth
    @number_of_invested_artists = @user.invested_artists.size
    @prospective_artists = Band.find_all_by_id( @user.associations.find(:all, :conditions => ['name = ?', 'watching']).collect{|a| a.band_id} )
    
    @random_band = get_random_band()

  end
  
  
  def manage_friends
    @user = User.find(session[:user_id])
    
    @random_band = get_random_band()
    
    #Start Geo logic!
    @zipcode_passed = params[:zipcode]
    if params[:zipcode] == 'Zip Code'
      zip = nil
    else
      zip = params[:zipcode]
    end

    if ( ( @zip = Zipcode.find_by_zipcode(zip) ) && ( @miles_away_passed = params[:miles_away].to_f ) )
      miles_away = params[:miles_away].to_f
      #1.8 used as a very scientific fudge factor -- yeah I know this isn't accurate, but nobody lives in the geographic center of their zip code anyway.
      lat_lower = @zip.latitude.to_f-(miles_away/(1.8*MILES_PER_DEGREE))
      lat_upper = @zip.latitude.to_f+(miles_away/(1.8*MILES_PER_DEGREE))
      longi_lower = @zip.longitude.to_f-(miles_away/(1.8*MILES_PER_DEGREE))
      longi_upper = @zip.longitude.to_f+(miles_away/(1.8*MILES_PER_DEGREE))
      zipcodes = Zipcode.find(:all, :conditions => ['latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?',lat_lower,lat_upper,longi_lower,longi_upper]).collect{|z| z.zipcode}
    end
    
    #now actually make the fans object
    if (zipcodes && !zipcodes.empty?)
      @friends = @user.friends.find_all_by_zipcode(zipcodes)
    else
      @friends = []
    end
    #End Geo logic!
    
    #give them random friends if they had an empty query
    if @friends.empty?
      @query_empty = true
      @friends = @user.friends.find(:all, :limit => 10, :order => 'RAND()')
    else
      @query_empty = false
    end
    
  end
  
  
  def purchases
    @user = User.find(session[:user_id])
    
    @random_band = get_random_band()
    @purchases = @user.google_checkout_orders.paginate(:order => ['created_at DESC'], :page => params[:user_purchases_page], :per_page => 20)
  end
  
=end  
protected

  def get_random_band()
    #this gets a random band playlist w/o dying 
    random_band = nil
    unless (Band.count == 0)
      for i in 1..10
        offset = rand(Band.count)
        random_band = Band.find(:first, :joins => :songs, :conditions => ['hidden = ?', false], :offset => offset)
        unless (random_band.nil? || random_band.playlist_songs.empty?)
          break
        end
      end
    end
    return (random_band || Band.new)
  end
  
  
#end controller
end
