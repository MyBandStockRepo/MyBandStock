class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      t.string :name
      t.integer :order
      t.float :multiplier
      t.integer :band_id

      t.timestamps
    end
  end

  def self.down
    drop_table :levels
  end
end
