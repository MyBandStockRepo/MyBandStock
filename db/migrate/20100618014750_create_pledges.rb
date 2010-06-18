class CreatePledges < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|
			t.belongs_to :pledged_band
			t.belongs_to :fan
      t.timestamps
    end
  end

  def self.down
    drop_table :pledges
  end
end
