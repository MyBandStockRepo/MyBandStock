class AddEconomicFieldsToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :earnable_shares_release_amount, :integer
    add_column :bands, :purchaseable_shares_release_amount, :integer
    add_column :bands, :share_price, :float
    add_column :bands, :min_share_purchase_amount, :integer
    add_column :bands, :max_share_purchase_amount, :integer
  end

  def self.down
    remove_column :bands, :max_share_purchase_amount
    remove_column :bands, :min_share_purchase_amount
    remove_column :bands, :share_price
    remove_column :bands, :purchaseable_shares_release_amount
    remove_column :bands, :earnable_shares_release_amount
  end
end
