class AddMenusKeysManagementPermission < ActiveRecord::Migration
  def self.up
    if const_defined?(:Permission)
      Permission.create :key => "menus_keys_management", :name => "Menus keys management"
    end
  end

  def self.down
    if const_defined?(:Permission)
      Permission.destroy_all(:key => %w[menus_keys_management])
    end
  end
end
