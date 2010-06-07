# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cobain::Application.initialize!


# ** Environment variables ** #

  #for user remember me
  SHA_SALT_STRING = 'saefhkw4qrtAFHW#fjhasejfa3sfa3sHSFAWa3412!@#$^@'

  # Time elapsed, in seconds, after which we consider a user to be not viewing a stream.
  #  We will allow him to reauthenticate after this amount of time, but not before this
  #  amount of time has elapsed. This is to prevent the user from sharing his viewer code.
  STREAM_VIEWER_TIMEOUT = 2*60 # seconds

  STREAMAPI_KEY = 'CGBSYICJLKEJQ3QYVH42S1N5SCTWYAN8'
  STREAMAPI_SECRET_KEY = 'BNGTHGJCV1VHOI2FQ7YWB5PO6NDLSQJK'

  TWITTERAPI_KEY = 'OxTeKBSHEM0ufsguoNNeg'
  TWITTERAPI_SECRET_KEY = 'VFB4ZuSSZ5PDZvhzwjU4NOzh4b1vQHfnBETfYLeOWw'

  TWEET_MAX_LENGTH = 140
