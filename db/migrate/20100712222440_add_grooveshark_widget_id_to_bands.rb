class AddGroovesharkWidgetIdToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :grooveshark_widget_id, :string
  end

  def self.down
    remove_column :bands, :grooveshark_widget_id
  end
end
