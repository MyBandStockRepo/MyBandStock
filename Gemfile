source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'haml', '3.0.3'
gem 'builder'
gem 'memcache-client' #need this for staging and production environments
gem 'money', '3.0.5' #we need money > 1.7 something but >3.0.5 requires rubygems>1.3.6 which dh can't handle
gem 'twitter', '>=0.9.12'
gem 'google4r'
gem 'google4r-checkout'
gem 'fastercsv' # For exporting a CSV of share codes

#following added by JM so we can run this under ruby 1.9
gem 'twitter-text', "1.1", :git => 'git://github.com/rubypond/twitter-text-rb.git'
gem 'will_paginate', :branch => "rails3"
#gem 'will_paginate'
gem 'newrelic_rpm', :require => false

#gem 'acts_as_dropdown', :git => 'git://github.com/gbdev/acts_as_dropdown.git'

#used to send out batch emails to multiple users
gem 'delayed_job', '>= 2.1.0.pre'

#used to see if batch emails need to be sent out
gem 'rufus-scheduler'


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'
# gem 'rails', :git => 'git://github.com/rails/auto_complete.git'

gem 'sqlite3-ruby', :require => 'sqlite3', :group => :development
gem 'ruby-mysql', :group => :production


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for certain environments:
# gem 'rspec', :group => :test
# group :test do
#   gem 'webrat'
# end
