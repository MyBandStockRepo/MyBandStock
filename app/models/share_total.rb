class ShareTotal < ActiveRecord::Base
  #IMPORTANT
  #It's always important to remember that users are the only ones granted shares. So whenever you see that some 'share' type object has both a user and a band; interpret that as, "The user has X shares in band Y".
  #The 'net' share total accounts for both positive and negative account adjustments
  #The 'gross' share total accounts only for positive account adjustments
  belongs_to :user
  belongs_to :band
end
