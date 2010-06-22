# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #helper_method :render_to_string

#	include Twitter::AuthenticationHelpers
#	rescue_from Twitter::Unauthorized, :with => :login	
	
	include SslRequirement
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  
  
  #prod stuff
  rescue_from ActionController::RoutingError, :with => :routingerror_exception
  rescue_from ActionController::UnknownAction, :with => :routingerror_exception
  rescue_from ActionController::InvalidAuthenticityToken, :with => :routingerror_exception  
  
  
  protect_from_forgery :secret => 'cbf5a700435e9c9137b5e3f8fea944887d78c5c74e684c48d256e0da9c8e081fc6b98180617556928d657c2460db54364b7518b804d7d93c12a4f7fd6c3f3acd'
  
  #the following line turns off layouts for all AJAX requests
  layout proc { |c| c.request.xhr? ? false : "application" }
  
  before_filter :fix_site_base_url
  
  #turns off sessions for search engine bots
  #session :off, :if => proc { |request| self.is_megatron?(request.user_agent) }

  #puts a variable in session related to the url ur at
  after_filter :update_last_location
  
  #basic layout
  layout "root-layout"
  
  ##########
  #CONSTANTS
  ##########
  
  MILES_PER_DEGREE = 69.17 #a best approximation is 69.17 given as distance of arc
  
  
  #################
  
  def index
    #unless params[:no_splash]
    #  redirect_to :controller => 'application', :action => 'event_splash'
    #  return
    #end

    if (session[:user_id])
      @user = User.find(session[:user_id])
      redirect_to '/me/control_panel'
    end
    @bands = Band.all(:limit => 10)
    if (session[:user_id])
      @user = User.find(session[:user_id])
    end
    
  end
  
  def event_splash
    # whatever the event splash needs
    render :layout => "event-layout"
  end
  
  def fan_home
    @bodytag_id = "homepages"
    authenticated?

=begin
    @spotlight_bands = Band.where(['status = ?', 'active'], :order => 'RAND()', :limit => 10)
    if @user = User.find_by_id(session[:user_id])
      @number_of_unopened_mail = @user.band_mails.find(:all, :conditions => ['opened = ?', false]).size
      @number_of_new_friends = 3
      @number_of_stage_posts_yesterday = 4
    end

    @news_templates = Rails.cache.fetch("fan_home_news", :expires_in => (15.minutes.from_now) ) do
      #assemble the news (if we need to)
      @news_templates = []
      
      source = BLOG_URL + '?feed=rss2' # url or local file
      content = "" # raw content of rss feed will be loaded here
      open(source) do |s| content = s.read end
      rss = RSS::Parser.parse(content, false)
      rss.items.each do |item|
        if (@news_templates.size == 3)
          break
        end
        if item.categories.select{|c| c.content == "Announcements"}.empty?
          next
        else
          nt = NewsTemplate.new
          nt.title = item.title
          nt.author = 'blah'
          nt.posted_at = item.date
          nt.body = item.description
          nt.link = item.link
          @news_templates << nt
        end
      end
      @news_templates
    end
=end
  end
  
  def band_home
    if @user = User.find_by_id(session[:user_id])
      @bands = @user.bands #associations.find_all(:joins => :band, :conditions => {:associations => {:name => ['admin', 'member']}}, :group => 'band_id').collect{|a| a.band}
    end
  end

  def authenticated?
    unless session[:auth_success] == true
      update_last_location # we need to run this after-filter manually here
      redirect_to :controller => :login, :action => :user, :lightbox => params[:lightbox]
    end
  end
  
  def has_role?(role)
    @user_roles = User.find(session[:user_id], :include => :roles).roles
    if @user_roles.include?(Role.find_by_name(role)) || @user_roles.include?(Role.find_by_name('site_admin'))
      return true
    else
      redirect_to :controller => 'application', :action => 'index'
    end
  end
 
  def captcha_valid?(answer)
    answer  = answer.gsub(/\W/, '')
    if (answer == '')
      return false
    end
    res = open("http://captchator.com/captcha/check_answer/#{session[:captcha_id]}/#{answer}").read.to_i.nonzero? rescue false
    if res
      session[:passed_captcha] = true
    else
      session[:passed_captcha] = false
    end
    return res
  end
 
  ##########
  protected
  ##########
  
  def ssl_required?
    # (Comment this one line out if you want to test ssl locally)
    return false if local_request? 
    # otherwise, use the filters.
    super
  end
  
	def local_request?
		request.remote_addr == '127.0.0.1' && request.remote_ip == '127.0.0.1'
	end
  
  def update_last_location
    session[:last_clean_url] = request.url
  end
  
  
  def user_is_staff?
    return has_role?('staff')
  end
  
  
  def user_has_site_admin
    unless ( session[:user_id] && User.find(session[:user_id]).site_admin == true )
      redirect_to '/me/control_panel'
      return false
    else
      true
    end
  end
  
  def user_is_part_of_a_band?
    if session[:user_id] && (User.find(session[:user_id]).is_part_of_a_band? || User.find(session[:user_id]).site_admin == true)
      return
    else
      redirect_to session[:last_clean_url]
    end
    
  end

  def user_is_admin_of_a_band?
    if session[:user_id] && (User.find(session[:user_id]).is_admin_of_a_band? || User.find(session[:user_id]).site_admin == true)
      return
    else 
      redirect_to session[:last_clean_url]
    end

  end
  
  def user_part_of_or_admin_of_a_band?
  	if session[:user_id] && (User.find(session[:user_id]).is_part_of_a_band? || User.find(session[:user_id]).is_admin_of_a_band? || User.find(session[:user_id]).site_admin == true)
  		return
  	else
			redirect_to session[:last_clean_url]  		
  	end
  end
  
  def get_band_id_from_request()
    id = nil #init ret val
    #if we got nothing send em away
    if params[:id].nil? && params[:band_short_name].nil? && params[:band_id].nil?
      redirect_to bands_path
    end
    
    #if we got a short_name convert it to an id
    if params[:band_short_name]
      band = Band.find_by_short_name(params[:band_short_name])
    end
    
    #make sure that was good
    unless band
      #make sure the params id corresponds to a band
      if !params[:id].nil? && Band.find_by_id(params[:id])
        id = params[:id]
      elsif !params[:band_id].nil? && Band.find_by_id(params[:band_id])
        id = params[:band_id]
      end
    else
      id = band.id
    end
    
    return id
  end

  def generate_key(length = 16)
  # Takes a string length and returns a random string
    chars = ("a".."z").to_a + ('A'..'Z').to_a + ("0".."9").to_a;
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end

  def render_json(json, options={})  
    callback, variable = params[:jsoncallback], params[:variable]  
    response = begin  
      if callback && variable  
        "var #{variable} = #{json};\n#{callback}(#{variable});"  
      elsif variable  
        "var #{variable} = #{json};"  
      elsif callback  
        "#{callback}(#{json});"  
      else  
        json  
      end  
    end  
    render({:content_type => :js, :text => response}.merge(options))  
  end  

	protected

#prod stuff
	def routingerror_exception
		redirect_to root_url
	end



  ##########
  private
  ##########
	def log_user_in(user_id)
		session[:auth_success] = true
		session[:user_id] = user_id
		user = User.find(user_id)
		if user
			session[:email] = user.email
			unless user.full_name.nil? || user.full_name == ''
				session[:full_name] = user.full_name
			end
		end
	end
  
  def is_megatron?(user_agent)
    user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end
  
  def fix_site_base_url
    return
    #unless ( (request.host_with_port =~ /#{SITE_URL.gsub(/http:\/\//, '')}/) || request.ssl? )
    #  redirect_to SITE_URL+request.fullpath
    #end
  end

#twitter stuff

  
    def band_oauth
#      @oauth ||= Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY, :sign_in => true)
      @band_oauth ||= Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY)
    end

    def user_oauth

      @user_oauth ||= Twitter::OAuth.new(TWITTERAPI_KEY, TWITTERAPI_SECRET_KEY)
    end
    

=begin
============================ CLIENT ============================
use_band_oauth -> Use the band's twitter oauth when using the twitter API, if true will look for
the band's credentials when doing things, ie. pull the band's tweets.  If false, will use the logged
in user's credentials when doing things, ie. posting a re-tweet

needs_band_member_status -> If true, requires that the logged in user is part of the band before
they can make the twitter API call ie. if someone wants to post a tweet, if false, the user dosesn't
have to be a part of the band for the twitter api call ie. user want's to view the band's tweets

band_id -> sets the ID for the band so their oauth token can be retrieved.  Only set if you want to
use the band's oauth
================================================================
=end    
    def client(use_band_oauth = false, needs_band_member_status = false, band_id = nil)
			user = User.find(session['user_id'])
      # want to use bands oauth to show posts but want non-band users to be able to view them
			if use_band_oauth
				if needs_band_member_status
					if band_id
						if user.has_band_admin(band_id) || user.is_member_of_band(band_id)
							thing = Band.find(band_id)
						else
							flash[:error] = 'You do not have permissions to use this Twitter function for this band.'
							return false
						end
					else
						flash[:error] = 'Could not get a band ID.'
						return false						
					end
				else
					thing = Band.find(band_id)
				end
			else
				thing = user
			end

			if thing.twitter_user
				if band_id.nil?
					user_oauth.authorize_from_access(thing.twitter_user.oauth_access_token, thing.twitter_user.oauth_access_secret)						
					Twitter::Base.new(user_oauth)
				else
					band_oauth.authorize_from_access(thing.twitter_user.oauth_access_token, thing.twitter_user.oauth_access_secret)						
					Twitter::Base.new(band_oauth)			
				end
			else
				flash[:error] = 'Could not find an authorized Twitter account.'
				return false				
			end
    end
		helper_method :client
		
end



