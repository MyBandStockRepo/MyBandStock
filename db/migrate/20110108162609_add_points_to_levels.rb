class AddPointsToLevels < ActiveRecord::Migration
  def self.up
    add_column :levels, :points, :integer
  end

  def self.down
    remove_column :levels, :points
  end
end
