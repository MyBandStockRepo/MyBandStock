class AddStartsOnToPromotionalCodes < ActiveRecord::Migration
  def self.up
    add_column :promotional_codes, :start_date, :datetime
  end

  def self.down
    remove_column :promotional_codes, :start_date
  end
end
