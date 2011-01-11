class Reward < ActiveRecord::Base
  belongs_to :level
  has_many :users, :through => :redemptions
  has_many :redemptions
end
