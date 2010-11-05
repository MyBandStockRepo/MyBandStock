class CreatePromotionalCodes < ActiveRecord::Migration
  def self.up
    create_table :promotional_codes do |t|
      t.string :code
      t.belongs_to :band
      t.datetime :expiration_date
      t.integer :share_value

      t.timestamps
    end
  end

  def self.down
    drop_table :promotional_codes
  end
end
