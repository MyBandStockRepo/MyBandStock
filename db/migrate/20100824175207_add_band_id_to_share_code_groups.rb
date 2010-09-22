class AddBandIdToShareCodeGroups < ActiveRecord::Migration
  def self.up
    add_column :share_code_groups, :band_id, :integer, :null => true
  end

  def self.down
    remove_column :share_code_groups, :band_id
  end
end
