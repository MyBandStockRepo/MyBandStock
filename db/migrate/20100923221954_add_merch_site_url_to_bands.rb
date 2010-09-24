class AddMerchSiteUrlToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :merch_site_url, :string
  end

  def self.down
    remove_column :bands, :merch_site_url
  end
end
