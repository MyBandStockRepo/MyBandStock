class ShortUrl < ActiveRecord::Base
  belongs_to :maker, :polymorphic => { :default => 'User' }
  
  def self.generate_short_url(long_url)
  # Takes an absolute URL and returns its shortened replacement.
    unless long_url
      return nil
    end
    #begin
      key = self.generate_key()
      logger.info "In generate loop"
    #end while ShortUrl.where(:key => key).count == 0
    
    key
  end
  
  private
  
  
  def self.generate_key(length = 4)
  # Takes a string length and returns a random string
    chars = ("a".."z").to_a + ('A'..'Z').to_a + ("0".."9").to_a;
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end

end

