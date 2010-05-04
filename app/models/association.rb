class Association < ActiveRecord::Base

  belongs_to :user
  belongs_to :band
  
  validates_numericality_of :band_id
  validates_numericality_of :user_id
  validates_presence_of :name
  
#end the model
end
