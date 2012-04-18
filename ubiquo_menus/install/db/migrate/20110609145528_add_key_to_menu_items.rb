class AddKeyToMenuItems < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :key, :string
  end

  def self.down
    remove_column :menu_items, :key
  end
end
