class Level < ActiveRecord::Base
  belongs_to :band
  has_many :rewards
  validates_uniqueness_of :name, :scope => :band_id
  default_scope :order => "points"
  has_many :users, :through => :share_totals
  
  #there might be a nicer way but it should work fine
  def next
    self.band.levels[band.levels.index(self) + 1]
  end
  
  def number
    levels = self.band.levels.order(:points)
    count = 1
    for lvl in levels
      if lvl.id == self.id
        return count
      end
      count += 1
    end
    
    return 0
  end  
end
