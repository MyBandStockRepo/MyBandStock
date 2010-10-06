class AddOfficialBandToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :mbs_official_band, :boolean, :default => false
  end

  def self.down
    remove_column :bands, :mbs_official_band
  end
end
