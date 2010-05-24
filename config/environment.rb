# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cobain::Application.initialize!

#for user remember me
SHA_SALT_STRING = 'saefhkw4qrtAFHW#fjhasejfa3sfa3sHSFAWa3412!@#$^@'

# Time elapsed, in seconds, after which we consider a user to be not viewing a stream.
#  We will allow him to reauthenticate after this amount of time, but not before this
#  amount of time has elapsed. This is to prevent the user from sharing his viewer code.
STREAM_VIEWER_TIMEOUT = 30 # seconds

