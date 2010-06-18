class CreatePledgedBands < ActiveRecord::Migration
  def self.up
    create_table :pledged_bands do |t|
      t.string :name
      t.string :description
      t.integer :pledges_count

      t.timestamps
    end
  end

  def self.down
    drop_table :pledged_bands
  end
end
