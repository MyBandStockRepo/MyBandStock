class Country < ActiveRecord::Base
   
   has_many :states
   
   
   def self.cached_all
     Rails.cache.fetch('Country.all') { all }
   end
end
