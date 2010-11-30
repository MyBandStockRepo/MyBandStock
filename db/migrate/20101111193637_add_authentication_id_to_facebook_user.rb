class AddAuthenticationIdToFacebookUser < ActiveRecord::Migration
  def self.up
    add_column :facebook_users, :authentication_id, :integer
  end

  def self.down
    remove_column :facebook_users, :authentication_id
  end
end
