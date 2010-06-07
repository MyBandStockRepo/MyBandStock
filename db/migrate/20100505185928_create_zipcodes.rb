require 'csv'

class CreateZipcodes < ActiveRecord::Migration
  def self.up
    create_table :zipcodes do |t|
      t.string :zipcode, {:null => false} 
      t.string :city, :state, {:null => false, :length => 50} 
      t.string :abbr, {:null => false, :length => 5} 
      t.string :latitude, :longitude, {:null => false} 
    end
    
=begin
    hash_holder = []
    reader = CSV.foreach("#{RAILS_ROOT}/lib/data/zipcodes.csv") do |row|
      Zipcode.create( :zipcode => (row[0] || ''), 
                       :latitude => (row[1] || ''), 
                       :longitude => (row[2] || ''), 
                       :city => (row[3] || ''), 
                       :state => (row[4] || ''), 
                       :abbr => (row[5] || '') )
            
    end
=end
    
  end

  def self.down
    drop_table :zipcodes
  end
end
