# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #helper_method :render_to_string

	include SslRequirement
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
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
    
    @bands = Band.all(:limit => 10)
  end

   #
  # Landing control panel
   #
  def cp
    authenticated?
    @user = User.find(session[:user_id])
    #render :layout => "cp-layout"
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
    @bodytag_id = "homepages"
    @spotlight_bands = Band.where(['status = ?', 'active'], :order => 'RAND()', :limit => 10)
    if @user = User.find_by_id(session[:user_id])
      @bands = @user.associations.find_all(:joins => :band, :conditions => {:associations => {:name => ['admin', 'member']}}, :group => 'band_id').collect{|a| a.band}
    end
=begin    
    @user_has_applied_for_band = BandApplication.find_by_user_id(session[:user_id], :conditions => ['approved != ?', false])

    @news_templates = Rails.cache.fetch("band_home_news", :expires_in => (15.minutes.from_now) ) do
      #assemble the news (if we need to)
      @news_templates = []
      
      source = BLOG_URL + '/?feed=rss2' # url or local file
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

  def authenticated?
      unless session[:auth_success] == true
          update_last_location # we need to run this after-filter manually here
          redirect_to :controller => :login, :action => :user
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
    unless ( User.find(session[:user_id]).site_admin == true )
      redirect_to '/me/control_panel'
      return false
    else
      true
    end
  end
  
  def user_is_part_of_a_band?
    if User.find(session[:user_id]).is_part_of_a_band?
      return
    else
      redirect_to session[:last_clean_url]
    end
    
  end

  def user_is_admin_of_a_band?
    if User.find(session[:user_id]).is_admin_of_a_band?
      return
    else 
      redirect_to session[:last_clean_url]
    end

  end
  
  
  def get_band_id_from_request()
    id = nil #init ret val
    #if we got nothing send em away
    if params[:id].nil? && params[:band_short_name].nil?
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
      else
        redirect_to bands_path
      end
    else
      id = band.id
    end
    
    return id
  end


  ##########
  private
  ##########

  
  def is_megatron?(user_agent)
    user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
  end
  
  def fix_site_base_url
    unless ( (request.host_with_port =~ /#{SITE_URL.gsub(/http:\/\//, '')}/) || request.ssl? )
      redirect_to SITE_URL+request.request_uri
    end
  end
  
  



end
