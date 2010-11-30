# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cobain::Application.initialize!


# will run the script to send out automated stream alert emails
#require 'lib/email_scheduler.rb'
# ** Environment variables ** #

####
# Share dispersal
#
  SHARE_LIMIT_LIFETIME        = 1.day
  NUM_SHARES_PER_BAND_PER_DAY = 1000
  MINIMUM_SHARE_PURCHASE      = 5       # Minimum number of shares per purchase.
  MBS_SHARE_PRICE             = 15      # cents; This is the price per share, in cents, of stock on the site.
                                        # @band.share_price() returns this if it is set.
####

# Email address to which support inquiries are sent.
# Currently displayed when a user does not have access to a stream, but tries to view it.
# Also shown when an error message is displayed when redeeming a code.
  MBS_SUPPORT_EMAIL = 'help@mybandstock.com'  #'support@mybandstock.com' bounces


#for user remember me
SHA_SALT_STRING = 'saefhkw4qrtAFHW#fjhasejfa3sfa3sHSFAWa3412!@#$^@'

# Time elapsed, in seconds, after which we consider a user to be not viewing a stream.
#  We will allow him to reauthenticate after this amount of time, but not before this
#  amount of time has elapsed. This is to prevent the user from sharing his viewer code.
STREAM_VIEWER_TIMEOUT = 2*60 #seconds

STREAMAPI_KEY = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
STREAMAPI_SECRET_KEY = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'

####
# Twitter
#
  TWITTERAPI_KEY            = 'OxTeKBSHEM0ufsguoNNeg'
  TWITTERAPI_SECRET_KEY     = 'VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw'
  TWEET_MAX_LENGTH          = 140
  NUM_SHARES_AWARDED_FOR_RT = 10

  Twitter.configure do |config|
    config.consumer_key = TWITTERAPI_KEY
    config.consumer_secret = TWITTERAPI_SECRET_KEY
  end  
  
####


####
# Facebook
#
#  FACEBOOK_APP_ID = 110251749041497
#  FACEBOOK_APP_SECRET = '158eb74a5eff840f0afb818e378f03aa'
####


URL_SHORTENER_HOST = 'http://mbs1.us'

####
# These keys must match exactly those of the ApiUser created in seeds. We use this user for internal
# permission granting. For example, when we apply share code permissions, we call the MBS API with
# these credentials.
  OUR_MBS_API_KEY = 'a3dcf5600b117fc0'
  OUR_MBS_API_SECRET_KEY = '7f5ba404ac8599fd0cf3623ebf84e97a'
  OUR_MBS_API_HASH = 'afc0c639f89e9e81230d457a1d4abe15bb3acaafe3345eef55e84754040823fe'
####

#this is the default value for the make public recording button
#if true it will default so that a recording is made publicly available for the stream
STREAMAPI_DEFAULT_PUBLIC_RECORDING = false

#Time.zone = "Eastern Time (US & Canada)"
