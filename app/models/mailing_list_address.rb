class MailingListAddress < ActiveRecord::Base
  before_create :lowercase_email_address
  before_save :lowercase_email_address
  validates_presence_of :email
  validates_uniqueness_of :email
  validates :email, :email => true
  
  private
    
    def lowercase_email_address
      self.email.downcase!
    end  
end
