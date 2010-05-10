class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.string :type, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :associations
  end
end
