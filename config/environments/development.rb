Cobain::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  
  
	
	# ENVIRONMENT CONSTANTS
	
	SITE_URL = 'http://127.0.0.1:3000'
	SECURE_SITE_URL = 'http://127.0.0.1:3000'
	SITE_HOST = '127.0.0.1:3000'
 
	
	STREAMS_URL = 'rtmp://localhost/vod'
  EMAIL_INTERCEPTOR_ADDRESS = 'brian@mybandstock.com'
  GOOGLE_CHECKOUT_CONFIGURATION = { :merchant_id => '330891329620486', :merchant_key => 'aFwCQ3T3icPNahynA_S6zA', :use_sandbox => true }
  
  #set timezone (only do for dev mode now so we don't break stuff on the server)
  #Time.zone = "Eastern Time (US & Canada)"

end
