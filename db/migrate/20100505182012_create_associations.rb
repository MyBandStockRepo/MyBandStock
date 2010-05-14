class CreateAssociations < ActiveRecord::Migration
  def self.up
    create_table :associations do |t|
      t.string :name, {:null => false, :length => 30} 

      #references
      t.belongs_to :user, :band

      t.timestamps

    end
  end

  def self.down
    drop_table :associations
  end
end
