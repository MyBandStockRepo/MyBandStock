class Authentication < ActiveRecord::Base
  belongs_to :user
  has_many :twitter_users
  has_many :facebook_users
  
  validates_uniqueness_of :user_id, :scope => :provider
  validates_uniqueness_of :provider, :scope => :uid
  
  before_create :one_account_per_user?
  
  def one_account_per_user?
    unless Authentication.where(:provider => provider, :uid => uid).all.count == 0
      puts "ERROR ENCOUNTERED"
      return false
    end
  end
  
end
