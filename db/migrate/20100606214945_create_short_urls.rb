class CreateShortUrls < ActiveRecord::Migration
  def self.up
    create_table :short_urls do |t|
      t.string :destination, {:null => false}
      t.string :key, {:null => false}

      t.belongs_to :maker, :polymorphic => { :default => 'User' }

      t.timestamps
    end
    add_index :short_urls, :key, { :unique => true }
  end

  def self.down
    drop_table :short_urls
  end
end
