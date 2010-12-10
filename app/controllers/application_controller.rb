# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

	
	include SslRequirement
	require 'uri'
  
  include ApplicationHelper
  
  #prod stuff
  rescue_from ActionController::RoutingError, :with => :routingerror_exception
  rescue_from ActionController::UnknownAction, :with => :routingerror_exception
  rescue_from ActionController::InvalidAuthenticityToken, :with => :routingerror_exception  
  
  
  protect_from_forgery :secret => 'cbf5a700435e9c9137b5e3f8fea944887d78c5c74e684c48d256e0da9c8e081fc6b98180617556928d657c2460db54364b7518b804d7d93c12a4f7fd6c3f3acd'
  
  #the following line turns off layouts for all AJAX requests
  layout proc { |c| c.request.xhr? ? false : "application" }
  
  before_filter :fix_site_base_url
  
  #puts a variable in session related to the url ur at
  after_filter :update_last_location

  # Stores the last controller and action in session[:last_controller], session[:last_action]
  after_filter :update_last_controller_and_action
  
  #basic layout
  layout "root-layout"
  
  ##########
  #CONSTANTS
  ##########
  
  MILES_PER_DEGREE = 69.17 #a best approximation is 69.17 given as distance of arc
  
  
  #################

  #a similar function also needs to be changed for the twitter crawler script in lib/twitter_crawler.rb
  def twitter_follower_point_calculation(followers)
    return (7*(Math.log(followers+1)+Math.exp(1))).round
  end
  
  def index    
    if (session[:user_id])
      @user = User.find(session[:user_id])
      redirect_to '/me/control_panel'
      flash[:error] = flash[:error]
      flash[:notice] = flash[:notice]
    end
  end  
  
  def event_splash
    # whatever the event splash needs
    render :layout => "event-layout"
  end
  
  def fan_home
    @bodytag_id = "homepages"
    authenticated?
  end
  
  def external_error
    render :layout => "white-label"
  end
  
  def band_home
    if @user = User.find_by_id(session[:user_id])
      # If a bandID was supplied, then show only that band. Otherwise, show all bands on which the user has permissions.
      if params[:band_id] && band = Band.where(:id => params[:band_id])
        @bands = band
      else
        @bands = @user.bands #associations.find_all(:joins => :band, :conditions => {:associations => {:name => ['admin', 'member']}}, :group => 'band_id').collect{|a| a.band}
      end
    end
    if !@bands
      flash[:error] = 'You do not manage any artists.'
      redirect_to '/me/home'
    end
  end
  
  def break_out_of_lightbox
  # This action breaks out of a lightbox, loading the supplied 'target' parameter as the new location of
  #   the lightbox's parent.
  #
    @target_location = params[:target] || ''
    render :layout => false
  end

  def authenticated?
    unless session[:auth_success] == true
      update_last_location # we need to run this after-filter manually here
      redirect_to :controller => :login, :action => :user, :lightbox => params[:lightbox]
      return false
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
  
  def came_from_band_site(band)
  # Returns true if the user looks like he came from the given band's site. Returns false if not, and nil if
  # bad params given. Checks if the referring host matches the band's access_schedule_url, short_name, or name.
  #
    return nil if band.nil?
    
    referer_domain  = URI.parse(request.referer).host  # Get 'www.google.com' from 'http://www.google.com'
    if band.access_schedule_url
      band_domain     = URI.parse(band.access_schedule_url).host
      match_location =
        referer_domain =~ /(#{band_domain}|#{band.short_name}|#{band.name.downcase.gsub(' ', '')})/
      
    else
      band_domain
      match_location =
        referer_domain =~ /(#{band.short_name}|#{band.name.downcase.gsub(' ', '')})/
      
    end

    logger.info "Referer: [#{referer_domain}]"
    
    # Convert to bool and return
    !!match_location
  end

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
  
  def update_last_controller_and_action
    session[:last_controller] = params[:controller]
    session[:last_action]     = params[:action]
    session[:last_id]         = params[:id] || params[:band_id] || params[:user_id]
  end
  
  
  def user_is_staff?
    return has_role?('staff')
  end
  
  
  def user_has_site_admin
    unless ( session[:user_id] && User.find(session[:user_id]).site_admin == true )
      redirect_to '/me/control_panel'
      return false
    else
      return true
    end
  end
  
  def user_is_part_of_a_band?
    if session[:user_id] && (User.find(session[:user_id]).is_part_of_a_band? || User.find(session[:user_id]).site_admin == true)
      return true
    else
      redirect_to session[:last_clean_url]
      return false
    end
    
  end

  def user_is_admin_of_a_band?
    if session[:user_id] && (User.find(session[:user_id]).is_admin_of_a_band? || User.find(session[:user_id]).site_admin == true)
      return true
    else 
      redirect_to session[:last_clean_url]
      return false      
    end

  end
  
  def user_part_of_or_admin_of_a_band?
  	if session[:user_id] && (User.find(session[:user_id]).is_part_of_a_band? || User.find(session[:user_id]).is_admin_of_a_band? || User.find(session[:user_id]).site_admin == true)
  		return true
  	else
			redirect_to session[:last_clean_url]  		
      return false			
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
      unless band
        # We search for many string variants of the given short_name.
        band = Band.search_by_name(params[:band_short_name])
      end
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
		return false
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
end



