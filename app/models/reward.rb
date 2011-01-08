class Reward < ActiveRecord::Base
  belongs_to :level
  belongs_to :band
  has_many :users, :through => :redemptions
  has_many :redemptions
end
