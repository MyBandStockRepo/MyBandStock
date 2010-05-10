class CreateBands < ActiveRecord::Migration
  def self.up
    create_table :bands do |t|
      t.string :name, :null => false
      t.text :bio
      t.string :city
      t.integer :zipcode
      t.string :band_photo
      t.string :status, :null => false, :default => "active"

      t.timestamps
    end
  end

  def self.down
    drop_table :bands
  end
end
