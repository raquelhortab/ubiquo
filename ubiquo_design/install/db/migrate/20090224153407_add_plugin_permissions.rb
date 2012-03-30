class AddPluginPermissions < ActiveRecord::Migration
  def self.up
    if const_defined?(:Permission)
      Permission.create :key => "design_management", :name => "Design management"
      Permission.create :key => "sitemap_management", :name => "Sitemap management"
    end
  end

  def self.down
    if const_defined?(:Permission)
      Permission.destroy_all(:key => %w[design_management sitemap_management])
    end
  end
end
