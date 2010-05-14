class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :password, :null => false
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zipcode
      t.string :phone
      t.string :status, :default => "pending", :null => false
      
      t.belongs_to :state
      t.belongs_to :country

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
