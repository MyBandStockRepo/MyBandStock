class AddPasswordSaltsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_salt, :string, :default => nil
  end

  def self.down
    remove_column :users, :password_salt    
  end
end
