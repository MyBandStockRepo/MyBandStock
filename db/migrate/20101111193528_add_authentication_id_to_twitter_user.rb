class AddAuthenticationIdToTwitterUser < ActiveRecord::Migration
  def self.up
    add_column :twitter_users, :authentication_id, :integer
  end

  def self.down
    remove_column :twitter_users, :authentication_id
  end
end
