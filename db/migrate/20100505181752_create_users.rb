class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
    
      t.string :first_name, :last_name, {:null => true, :length => 50}
      t.string :password, {:null => false} 
      t.text :bio, {:null => true}
      t.string :address1, :address2, :city, {:null => true, :length => 50} 
      t.string :email, {:null => false, :length => 60} 
      t.string :zipcode, {:null => true, :length => 20} 
      t.string :phone, {:null => true, :length => 20} 
      t.boolean :agreed_to_tos, :agreed_to_pp, {:null => false, :default => false}  
      t.integer :headline_photo_id, {:null => true}
      t.string :status, {:default => "pending", :null => false}
      
      #references
      t.belongs_to :country, :state        
    
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
