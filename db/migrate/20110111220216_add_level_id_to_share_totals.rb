class AddLevelIdToShareTotals < ActiveRecord::Migration
  def self.up
    add_column :share_totals, :level_id, :integer
  end

  def self.down
    remove_column :share_totals, :level_id
  end
end
