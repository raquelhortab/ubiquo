class CreateMenuItems < ActiveRecord::Migration
  def self.up
    uhook_create_menu_items_table do |t|
      t.integer :parent_id
      t.string :caption
      t.string :url
      t.text :description
      t.boolean :is_linkable, :default => false
      t.boolean :is_active, :default => true
      t.integer :position
      t.integer :menu_id
      t.integer :page_id

      t.timestamps
    end
  end

  def self.down
    drop_table :menu_items
  end
end
