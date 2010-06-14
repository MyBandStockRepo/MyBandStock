Cobain::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

	
	SITE_URL = 'http://cobain.mybandstock.com'
	SECURE_SITE_URL = 'http://cobain.mybandstock.com'
	SITE_HOST = 'cobain.mybandstock.com'
  # Email address to which support inquiries are sent.
  # Currently displayed when a user does not have access to a stream, but tries to view it.
  MBS_SUPPORT_EMAIL = 'support@mybandstock.com'


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