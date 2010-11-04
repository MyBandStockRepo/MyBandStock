class PromotionalCode < ActiveRecord::Base
  belongs_to :band
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :code
  validates_presence_of :code, :start_date, :expiration_date, :band_id, :share_value
  validates_numericality_of :share_value
  validate :start_date_before_expiration_date
  
  def start_date_before_expiration_date
    #make sure the start date is before the end date
    if self.start_date > self.expiration_date
      errors.add(:expiration_date, "This must be after the start date.")      
    end 
  end
end
