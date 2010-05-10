require 'csv'

class CreateCountryIps < ActiveRecord::Migration
  def self.up
    create_table :country_ips do |t|
      t.string :begin_ip, :end_ip
      t.integer :begin_num, :end_num
      t.string :country_code, :name 
    end
    
    #populate with data, note that this list is semi-colon delimited
    reader = CSV.open("#{RAILS_ROOT}/lib/data/GeoIPCountryWhois.csv", 'r') do |row|
      CountryIp.create(:begin_ip => row[0], 
                      :end_ip => row[1], 
                      :begin_num => row[2], 
                      :end_num => row[3], 
                      :country_code => row[4], 
                      :name => row[5])
    end
  end

  def self.down
    drop_table :country_ips
  end
end
