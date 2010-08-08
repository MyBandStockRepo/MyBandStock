class AddTransactionIdToShareLedgerEntries < ActiveRecord::Migration
  def self.up
    add_column :share_ledger_entries, :transaction_id, :integer, :null => true
  end

  def self.down
    remove_column :share_ledger_entries, :transaction_id
  end
end
