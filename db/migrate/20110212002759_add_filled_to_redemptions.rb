class AddFilledToRedemptions < ActiveRecord::Migration
  def self.up
    add_column :redemptions, :filled, :boolean, :default => false
  end

  def self.down
    remove_column :redemptions, :filled
  end
end
