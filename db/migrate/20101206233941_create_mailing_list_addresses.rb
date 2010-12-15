class CreateMailingListAddresses < ActiveRecord::Migration
  def self.up
    create_table :mailing_list_addresses do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :mailing_list_addresses
  end
end
