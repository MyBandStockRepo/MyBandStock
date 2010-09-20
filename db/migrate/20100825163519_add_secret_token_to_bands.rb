class AddSecretTokenToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :secret_token, :string
  end

  def self.down
    remove_column :bands, :secret_token
  end
end
