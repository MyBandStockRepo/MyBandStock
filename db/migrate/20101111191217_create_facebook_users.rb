class CreateFacebookUsers < ActiveRecord::Migration
  def self.up
    create_table :facebook_users do |t|
      t.string :facebook_id
      t.string :name
      t.string :location
      t.string :email
      t.string :gender
      t.string :access_token

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_users
  end
end
