class AddAddress1ToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :address1, :string
  end

  def self.down
    remove_column :users, :address1
  end
end
