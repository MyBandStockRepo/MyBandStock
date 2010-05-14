class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :password, :null => false
      t.string :address
      t.string :city
      t.integer :zipcode
      t.string :phone
      t.integer :country_id
      t.string :status, :default => "pending", :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
