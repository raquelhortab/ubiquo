class CreateMenus < ActiveRecord::Migration
  def self.up
    uhook_create_menus_table do |t|
      t.string :name
      t.string :key
      t.timestamps
    end
  end

  def self.down
    drop_table :menus
  end
end
