class ShareCodeGroup < ActiveRecord::Base
  has_many :share_codes
  belongs_to :band
end
