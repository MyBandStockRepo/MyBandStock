class CreateRedemptions < ActiveRecord::Migration
  def self.up
    create_table :redemptions do |t|
      t.integer :user_id
      t.integer :reward_id

      t.timestamps
    end
  end

  def self.down
    drop_table :redemptions
  end
end
