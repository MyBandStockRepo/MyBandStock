class AddUserIdAndBandIdAndNumSharesToPledges < ActiveRecord::Migration
  def self.up
    add_column :pledges, :user_id, :integer, :null => true
    add_column :pledges, :band_id, :integer, :null => true
    add_column :pledges, :num_shares, :integer, :null => true
  end

  def self.down
    remove_column :pledges, :band_id
    remove_column :pledges, :user_id
    remove_column :pledges, :num_shares
  end
end
