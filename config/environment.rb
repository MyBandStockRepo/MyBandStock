# Load the rails application
require File.expand_path('../application', __FILE__)
#require "will_paginate"

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


URL_SHORTENER_HOST = 'http://mbs1.us'

# These keys must match exactly those of the ApiUser created in seeds. We use this user for internal
# permission granting. For example, when we apply share code permissions, we call the MBS API with
# these credentials.
OUR_MBS_API_KEY = 'a3dcf5600b117fc0'
OUR_MBS_API_SECRET_KEY = '7f5ba404ac8599fd0cf3623ebf84e97a'
OUR_MBS_API_HASH = 'afc0c639f89e9e81230d457a1d4abe15bb3acaafe3345eef55e84754040823fe'

