class AddLocationToTwitterUsers < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :location, :string
  end

  def self.down
    remove_column :twitter_users, :location
  end
end
