class Level < ActiveRecord::Base
  belongs_to :band
  has_many :rewards
  validates_uniqueness_of :name, :scope => :band_id
  default_scope :order => "points"
  has_many :users, :through => :share_totals
end
