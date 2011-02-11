class Redemption < ActiveRecord::Base
  validates_presence_of :reward_id
  validates_presence_of :user_id
  belongs_to :reward
  belongs_to :user
end
