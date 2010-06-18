class PledgedBand < ActiveRecord::Base
  has_many :pledges
#  has_many :users,:through => :pledges
  has_many :fans,:through => :pledges
  
  validates_uniqueness_of :name
end
