class ShareCodeGroup < ActiveRecord::Base
  has_many :share_codes
  
  validates_presence_of :start_share_code_id, :num_share_codes
  
end
