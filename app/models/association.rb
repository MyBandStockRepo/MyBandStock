class Association < ActiveRecord::Base

  belongs_to :user
  belongs_to :band
  
  validates_numericality_of :band_id
  validates_numericality_of :user_id
  validates_presence_of :name
  def self.find_admin(user_id, band_id)
    joins(:user, :band).where("band_id = #{band_id} and user_id = #{user_id} and name != 'member' and name != 'fan'")
  end
#end the model
end
