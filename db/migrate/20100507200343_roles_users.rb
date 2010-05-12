class RolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.timestamps
      #references
      t.belongs_to :role, :user
    end

  end

  def self.down
    drop_table :roles_users
  end
end
