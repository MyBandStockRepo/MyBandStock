class AddTwitterUsernameToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :twitter_username, :string, :null => true
  end

  def self.down
    remove_column :bands, :twitter_username
  end
end
