class CreateShareCodeGroups < ActiveRecord::Migration
  def self.up
    create_table :share_code_groups do |t|
    
      t.string  :label,               { :null => true }   # Aesthetic name
      t.integer :share_codes_count
      t.boolean :active,              { :null => false, :default => true } # like "valid"
      t.integer :share_amount,        { :null => true }
      t.datetime :expires_on,    { :null => true }

      t.timestamps
    end
  end

  def self.down
    drop_table :share_code_groups
  end
end
