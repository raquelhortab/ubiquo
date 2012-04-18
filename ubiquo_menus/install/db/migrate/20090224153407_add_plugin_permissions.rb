class AddPluginPermissions < ActiveRecord::Migration
  def self.up
    if const_defined?(:Permission)
      Permission.create :key => "menus_management", :name => "Menus management"
    end
  end

  def self.down
    if const_defined?(:Permission)
      Permission.destroy_all(:key => %w[menus_management])
    end
  end
end
