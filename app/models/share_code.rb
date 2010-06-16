class ShareCode < ActiveRecord::Base
  belongs_to :share_code_group, :counter_cache => true
  belongs_to :user
  
  validates_presence_of :key
  validates_uniqueness_of :key

end
