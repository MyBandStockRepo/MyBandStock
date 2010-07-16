require 'csv'

class PopulateStates < ActiveRecord::Migration
  def self.up
    #make the not spec state
    State.create(:name => 'Not Specified', :abbreviation => 'N/A', :country_id => 1)
      #populate with USA data
      #first find the USA country
      usa = Country.where(:abbreviation => "US").first
      if usa.nil?
        usa_id = 233
      else
        usa_id = usa.id        
      end
      reader = CSV.foreach("#{RAILS_ROOT}/lib/data/usa_states.csv") do |row|
        State.create(:name => row[0], :abbreviation => row[1], :country_id => usa_id)
    end
  end

  def self.down
  end
end
