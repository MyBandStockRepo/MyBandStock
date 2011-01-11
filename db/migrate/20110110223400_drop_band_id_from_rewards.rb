class DropBandIdFromRewards < ActiveRecord::Migration
  def self.up
    remove_column :rewards, :band_id
  end

  def self.down
    add_column :rewards, :band_id, :integer
  end
end
