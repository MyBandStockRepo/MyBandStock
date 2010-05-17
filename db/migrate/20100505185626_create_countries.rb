require 'csv'

class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name, {:null => false, :length => 50}
      t.string :abbreviation, {:null => false, :length => 4}
      t.timestamps
    end
    
    #make the not spec country
    Country.create(:name => 'Not Specified', :abbreviation => 'N/A')
    
    #populate with data, note that this list is semi-colon delimited
    reader = CSV.open("#{RAILS_ROOT}/lib/data/countries.csv", 'r', ?;) do |row|
      Country.create(:name => row[0], :abbreviation => row[1])
    end    
  end

  def self.down
    drop_table :countries
  end
end
