class AddBelongsToFieldsToBand < ActiveRecord::Migration
  def self.up
    add_column :bands, :country_id, :integer
    add_column :bands, :state_id, :integer
  end

  def self.down
    remove_column :bands, :state_id
    remove_column :bands, :country_id
  end
end
