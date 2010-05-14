class CreateBands < ActiveRecord::Migration
  def self.up
    create_table :bands do |t|
    
      t.string :name, {:null => false, :length => 50}
      t.string :short_name, {:null => false, :length => 30}
      t.text :bio, {:null => false, :length => 2000}
      t.boolean :terms_of_service {:null => false, :default => false}
      t.string :city, {:null => false, :length => 50}
      t.integer :zip_code, {:null => false, :length => 10} 
      t.string :band_photo
      t.string :status, {:null => false, :default => "active"}
      t.string :twitter_user
      #references
      t.belongs_to :country, :state    

      t.timestamps
    end
  end

  def self.down
    drop_table :bands
  end
end
