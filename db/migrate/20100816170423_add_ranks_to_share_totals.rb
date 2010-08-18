class AddRanksToShareTotals < ActiveRecord::Migration
  def self.up
    add_column :share_totals, :last_rank, :integer  
    add_column :share_totals, :current_rank, :integer      
  end
  

  def self.down
    remove_column :share_totals, :last_rank    
    remove_column :share_totals, :current_rank    
  end
end
