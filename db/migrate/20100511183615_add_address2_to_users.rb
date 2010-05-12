class AddAddress2ToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :address2, :string
  end

  def self.down
    remove_column :users, :address2
  end
end
