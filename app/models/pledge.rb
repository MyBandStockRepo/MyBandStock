class Pledge < ActiveRecord::Base
  belongs_to :pledged_band, :counter_cache => true
#  belongs_to :user
  belongs_to :fan
  
  accepts_nested_attributes_for :pledged_band
#  accepts_nested_attributes_for :user
  
  def pledge_amount=(amount)
    current_pledge_amount = amount
  end
  
  def pledge_amount
    current_pledge_amount
  end
  
end
