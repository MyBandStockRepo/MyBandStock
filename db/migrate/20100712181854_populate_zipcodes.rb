require 'csv'

class PopulateZipcodes < ActiveRecord::Migration
  def self.up
    # Populate Zipcodes table
    hash_holder = []
    reader = CSV.foreach("#{RAILS_ROOT}/lib/data/zipcodes.csv") do |row|
      Zipcode.create( :zipcode => (row[0] || ''), 
                       :latitude => (row[1] || ''), 
                       :longitude => (row[2] || ''), 
                       :city => (row[3] || ''), 
                       :state => (row[4] || ''), 
                       :abbr => (row[5] || '') )
        
    end
  end

  def self.down
  end
end

