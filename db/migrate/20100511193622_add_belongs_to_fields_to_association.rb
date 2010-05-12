class AddBelongsToFieldsToAssociation < ActiveRecord::Migration
  def self.up
    add_column :associations, :user_id, :integer, {:null => false, :default => 0}
    add_column :associations, :band_id, :integer, {:null => false, :default => 0}
  end

  def self.down
    remove_column :associations, :band_id
    remove_column :associations, :user_id
  end
end
