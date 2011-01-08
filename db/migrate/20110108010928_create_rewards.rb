class CreateRewards < ActiveRecord::Migration
  def self.up
    create_table :rewards do |t|
      t.string :name
      t.integer :level_id
      t.integer :band_id
      t.text :description
      t.datetime :expires_at
      t.integer :limit

      t.timestamps
    end
  end

  def self.down
    drop_table :rewards
  end
end
