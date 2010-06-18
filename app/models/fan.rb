class Fan < ActiveRecord::Base
  
  #CALLBACKS
  before_create :lowercase_email_address

  #ASSOCIATIONS
  has_many :pledges
  has_many :pledged_bands,:through => :pledges
  
  #VALIDATIONS
  validate :valid_name?
  validates_presence_of :first_name
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => "Invalid Email"
  
  #VALIDATE FAN NAME string != "NAME")
  def valid_name?
     unless first_name != "Name"
       errors.add(:name, "Ivalid Name")
     end
  end

  #Full Name Virtual Attributes
  #FRIST/LAST NAMES ARE TITLELIZE FOR DATA INTEGRITY
  def full_name
    [first_name, last_name].join(' ')
  end
  
  def full_name=(name)
    split = name.split(' ', 2)
    
    if split.size == 1
      #if full_name is 1 word make it first_name only
      f_name = split.first.upcase
      f_name.capitalize! 
      self.first_name = f_name
    elsif split.size == 2
      #firt_name
      f_name = split.first.upcase
      f_name.capitalize! 
      self.first_name = f_name
      #last_name
      l_name = split.last.downcase
      l_name.capitalize!
      self.last_name = l_name
    end
     
  end
  
  #PASSES THE BAND_NAME ATTRIBUTE ALONG AS PARAMETER
  def fan_new_pledged_band
  end
  
  def fan_new_pledged_band=(band_name)
    pledged_band = band_name
  end
  
  
  private
    
    def lowercase_email_address
      self.email.downcase!
    end
end