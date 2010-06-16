class CreateShareCodes < ActiveRecord::Migration
  def self.up
    create_table :share_codes do |t|
      t.string :key, { :null => false }
      t.boolean :redeemed, { :null => false, :default => false }

      t.belongs_to :share_code_group, {:null => true}
      t.belongs_to :user, { :null => true }
      t.timestamps
    end

    add_index :share_codes, :key, { :unique => true }
  end

  def self.down
    drop_table :share_codes
  end
end
