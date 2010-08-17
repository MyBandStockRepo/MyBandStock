class AddCommerceAllowedToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :commerce_allowed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :bands, :commerce_allowed
  end
end
