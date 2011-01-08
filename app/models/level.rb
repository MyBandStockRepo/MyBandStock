class Level < ActiveRecord::Base
  belongs_to :band
  has_many :rewards
end
