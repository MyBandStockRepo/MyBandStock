Cobain::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb


  # Email address to which support inquiries are sent.
  # Currently displayed when a user does not have access to a stream, but tries to view it.
  MBS_SUPPORT_EMAIL = 'support@mybandstock.com'

  ####
  # Facebook
  # 
  FACEBOOK_APP_ID = 144291128954782
  FACEBOOK_APP_SECRET = 'efa0156e42947617a3168000fa8bcd8d'
  #
  ####

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql
  SITE_URL = 'http://127.0.0.1:3000'
	SECURE_SITE_URL = 'http://127.0.0.1:3000'
	SITE_HOST = '127.0.0.1:3000'
 
  ####
  # Facebook
  # 
  FACEBOOK_APP_ID = 144291128954782
  FACEBOOK_APP_SECRET = 'efa0156e42947617a3168000fa8bcd8d'
  #
  ####
 
	STREAMS_URL = 'rtmp://localhost/vod'

  EMAIL_INTERCEPTOR_ADDRESS = 'brian@mybandstock.com'

  GOOGLE_CHECKOUT_CONFIGURATION = { :merchant_id => '330891329620486', :merchant_key => 'aFwCQ3T3icPNahynA_S6zA', :use_sandbox => true }
  
end
