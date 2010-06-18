class CreateShareLedgerEntries < ActiveRecord::Migration
  def self.up
    create_table :share_ledger_entries do |t|
      t.integer :adjustment, {:null => false}
      t.string :description, {:null => false}
      
      t.belongs_to :user, {:null => false}
      t.belongs_to :band, {:null => false}
      
      t.timestamps
    end
  end

  def self.down
    drop_table :share_ledger_entries
  end
end
