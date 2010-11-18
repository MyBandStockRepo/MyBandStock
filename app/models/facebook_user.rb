class FacebookUser < ActiveRecord::Base
  belongs_to :authentication
  validates_presence_of :facebook_id
  validates_uniqueness_of :facebook_id
end
