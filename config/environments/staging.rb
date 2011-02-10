Cobain::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

	
  SITE_URL = 'http://notorious.mybandstock.com'
  SECURE_SITE_URL = 'http://gary.mybandstock.com'
  SITE_HOST = 'gary.mybandstock.com'
  
  
  ####
  # Facebook
  # 
  FACEBOOK_APP_ID = 110251749041497
  FACEBOOK_APP_SECRET = '158eb74a5eff840f0afb818e378f03aa'
  #
  ####  
  
  GOOGLE_CHECKOUT_CONFIGURATION = { :merchant_id => '330891329620486', :merchant_key => 'aFwCQ3T3icPNahynA_S6zA', :use_sandbox => true }

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are ENABLED and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in staging
  config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!
end
