class CreateShareTotals < ActiveRecord::Migration
  def self.up
    create_table :share_totals do |t|
      t.integer :net
      t.integer :gross
      
      t.belongs_to :user
      t.belongs_to :band
      t.timestamps
    end
  end

  def self.down
    drop_table :share_totals
  end
end
