class Reward < ActiveRecord::Base
  belongs_to :level
  has_many :redemptions
  has_many :users, :through => :redemptions
  
  def redeemable_by(user)
    ShareTotal.get_with_band_and_user_ids(self.level.band.id, user.id).net >= self.points && user.has_not_redeemed?(self)
  end
end
