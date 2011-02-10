class AddDescriptionToLevels < ActiveRecord::Migration
  def self.up
    add_column :levels, :description, :text
    add_column :levels, :limit, :integer
    rename_column :levels, :order, :position
  end

  def self.down
    rename_column :levels, :position, :order
    remove_column :levels, :limit
    remove_column :levels, :description
  end
end
