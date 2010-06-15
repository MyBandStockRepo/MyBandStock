class ShortUrl < ActiveRecord::Base
  belongs_to :maker, :polymorphic => { :default => 'User' }
  
  def self.generate_short_url(long_url, maker = nil)
  # Takes an absolute URL and returns its shortened replacement.
  # Also takes a maker, which can be either a User or a Band object.
  # For example, if the maker is a User, he is the one who gets rewarded for link clicks.

    return nil unless long_url
    
    # Limit maker to a Band or User object
    maker = nil if ['Band', 'User'].include? maker.class

    begin
      key = self.generate_key()
    end while ShortUrl.where(:key => key).count != 0

    self.create(
                :destination => long_url,
                :key => key,
                :maker_type => (maker) ? maker.class : nil,
                :maker_id => (maker) ? maker.id : nil
         )

    host = URL_SHORTENER_HOST || 'http://mbs1.us'
    return host + '/' + key
  end
  
  private
  
  
  def self.generate_key(length = 4)
  # Takes a string length and returns a random string
    chars = ("a".."z").to_a + ('A'..'Z').to_a + ("0".."9").to_a;
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end

end

