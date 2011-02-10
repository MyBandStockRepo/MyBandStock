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
  end

  def self.down
    drop_table :countries
  end
end
