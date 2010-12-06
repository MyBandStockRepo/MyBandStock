require 'net/http'
require 'uri'
require 'rexml/document'
include REXML

class BandsController < ApplicationController
  
 protect_from_forgery :only => [:create, :update]
 before_filter :authenticated?, :except => [:show, :is_band_broadcasting_live, :index, :leaderboard_widget]
# skip_filter :update_last_location, :except => [:index, :show, :control_panel, :manage_users, :manage_project, :manage_music, :manage_photos, :manage_perks, :manage_fans, :inbox]
 before_filter :user_is_admin_of_a_band?, :except => [:show, :create, :new, :buy_stock, :is_band_broadcasting_live, :index, :leaderboard_widget]
 skip_filter :update_last_location, :except => [:index, :show, :edit, :new, :control_panel, :manage_users, :leaderboard_widget, :stats]

# Plot a graph of Twitter mentions by date for the last week
# Docs at http://code.google.com/apis/chart/docs/chart_wizard.html
def graph
  return unless @band = Band.find_by_id(params[:id])
  # Extract Twitter mentions within a week, grouped by date
  dates_and_mentions = @band.twitter_crawler_trackers.recent.by_date.count(:id)
  dates = dates_and_mentions.collect{|mention| mention.first.to_date.day}.join "|"
  mentions = dates_and_mentions.collect{|mention| mention.second}.join ","
  # Add some basic properties to the chart
  size = "300x225"
  title = CGI.escape "Twitter mentions for #{@band.name}"
  color = "3D7930"
  dates_pos = (1..dates_and_mentions.size).to_a.join ","
  dates_count = [1,dates_and_mentions.size].join ","
  @graph_url = "http://chart.apis.google.com/chart?chxl=1:|#{dates}&chxp=1,#{dates_pos}&chxr=1,#{dates_count}&chxt=y,x&chs=#{size}&cht=lc&chco=#{color}&chd=t:#{mentions}&chg=14.3,-1,1,1&chls=2,4,0&chm=B,C5D4B5BB,0,0,0&chtt=#{title}"
end


def dashboard
# Action for the Artist Dashboard. Main page is the statistics page.
# Only viewable to band admins.
#
  redirect_to root_url and return if params[:band_id].blank?
  @band = Band.where(:id => params[:band_id]).first
  redirect_to root_url and return unless @band
  
  # time_range_start = 
  # time_range_end = 
    
  @top_fans         = @band.top_shareholders(10)
  @top_influencers  = @band.top_influencers(10)
  @top_purchasers   = @band.top_purchasers(10)

  @num_total_fans     = @band.share_totals.where('net >= 0').count
  @num_new_fans       = @num_total_fans # @band.share_totals.joins(:user).includes(:user).where('net >= 0').where('users.created_at > ?', Time.now - time_range_start).count
  @num_total_mentions = @band.num_total_mentions
  
  if Rails.env == 'development'
    @tweets_per_day_data = '[[1287903600000, 79], [1287990000000, 25], [1288076400000, 61], [1288162800000, 30], [1288249200000, 22], [1288335600000, 21], [1288422000000, 6], [1288508400000, 21], [1288594800000, 4], [1288681200000, 13], [1288767600000, 25], [1288854000000, 15], [1288940400000, 32], [1289026800000, 29], [1289113200000, 7], [1289203200000, 8], [1289289600000, 10], [1289376000000, 10], [1289462400000, 10], [1289548800000, 29], [1289635200000, 15], [1289721600000, 19], [1289808000000, 7], [1289894400000, 26], [1289980800000, 15], [1290067200000, 24], [1290153600000, 32], [1290240000000, 10], [1290326400000, 18], [1290412800000, 14], [1290499200000, 4]]'
  else
    @tweets_per_day_data = @band.tweets_per_day_as_string
  end

  render 'bands/dashboard/statistics' and return
end


def stats
  if params[:band_id] && @band = Band.find(params[:band_id])
    @twitter_hash_tags = @band.twitter_crawler_hash_tags
    @twitter_trackers = @band.twitter_crawler_trackers
    @twitter_users = @twitter_trackers.collect{|t| t.twitter_user}
    @twitter_users = @twitter_users.uniq
    @retweets = Retweet.where(:band_id => @band.id).all
    @retweet_twitter_users = @retweets.collect{|rt| rt.twitter_user}
    @registered_users = []
    @unregistered_users = []
    for t_user in @twitter_users
      if t_user.users.last.nil?
        @unregistered_users << t_user
      else
        @registered_users << t_user
      end
    end
    @users = @registered_users.collect{|u| u.users.last}    
    
  else
    flash[:error] = "Could not find artist ID."
    return false
  end
end

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
 
 
  def leaderboard_widget
  # Action for the external leaderboard widget for a given band.
  # Parameters:
  #   band_id
  #
    if params[:band_id].blank?
      render :nothing => true and return
    end
    
    @band = Band.where(:id => params[:band_id]).first
    
    unless @band
      render :nothing => true and return
    end
    
    @top_stockholders = @band.top_shareholders(5)
    @twitter_set_status_url = "http://twitter.com/home?status="
    @twitter_hashtag = (@band.twitter_crawler_hash_tags.first && @band.twitter_crawler_hash_tags.first.term) || '%23' + @band.name.gsub(' ', '')
    @twitter_status_text = "Rock on! Tweet #{@twitter_hashtag} for BandStock!"
    @twitter_set_status_link = @twitter_set_status_url + @twitter_status_text
    
    if session[:user_id]
      # If the user is logged in, we provide his rank.
      user = User.where(:id => session[:user_id]).first
      if user
        @user_rank = user.shareholder_rank_for_band(@band.id)
      end
    end
    
    render :layout => 'leaderboard_widget_layout'
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
    @points_per_retweet = twitter_follower_point_calculation(0)
    available_shares = @band.available_shares_for_earning
    if available_shares && available_shares < @points_per_retweet
      @points_per_retweet = available_shares
    end
    
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
			if @user && @user.twitter_user
				@twit_user = @user.twitter_client.verify_credentials
			  @points_per_retweet = twitter_follower_point_calculation(@twit_user.followers_count)
				available_shares = @band.available_shares_for_earning
        if available_shares && available_shares < @points_per_retweet
          @points_per_retweet = available_shares
        end					
			end    
		rescue
			@points_per_retweet = twitter_follower_point_calculation(0)	
			available_shares = @band.available_shares_for_earning
      if available_shares && available_shares < @points_per_retweet
        @points_per_retweet = available_shares
      end
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
				@twit_band = @band.twitter_client.verify_credentials
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
				@twit_band = @band.twitter_client.verify_credentials
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
				@twit_band = @band.twitter_client.verify_credentials
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
				@twit_band = @band.twitter_client.verify_credentials
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
      flash[:notice] = 'Artist created successfully.'
      
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
        render :text => "You've attempted to buy stock from an invalid artist. Please try again.", :layout => 'lightbox'
      else
        flash[:notice] = "You've attempted to buy stock from an invalid artist. Please try again."
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
  
  def shareholders
    @band = Band.find(params[:band_id])
    @shareholders = @band.all_shareholder_users
  end
  
  
  
  
protected
  
  
  
  
private



end
