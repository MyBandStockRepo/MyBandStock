class CreateApiUsers < ActiveRecord::Migration
  def self.up
    create_table :api_users do |t|
      t.string :api_key, :null => false
      t.string :secret_key, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :api_users
  end
end
