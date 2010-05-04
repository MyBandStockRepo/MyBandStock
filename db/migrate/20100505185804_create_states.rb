require 'csv'

class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.string :name, {:null => false, :length => 30}
      t.string :abbreviation, {:null => false, :length => 5}
      #references
      t.belongs_to :country
      t.timestamps
    end
   
    #make the not spec state
    State.create(:name => 'Not Specified', :abbreviation => 'N/A', :country_id => 1)
    
    #populate with USA data
    #first find the USA country
    usa_id = Country.find_by_abbreviation("US").id
    reader = CSV.open("#{RAILS_ROOT}/lib/data/usa_states.csv", 'r') do |row|
      State.create(:name => row[0], :abbreviation => row[1], :country_id => usa_id)
    end
  end

  def self.down
    drop_table :states
  end
end
