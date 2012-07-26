# An AssetGeometry is the geometry for each style processed for an Asset
# It used to save all the geometries and do not calutate it later
class AssetGeometry < ActiveRecord::Base
  belongs_to :asset

  validates :asset_id, :style, :width, :height, :presence => true
  validates :width, :height, :numericality => { :only_integer => false,
                                                :greater_than => 0 }
  validates :style, :uniqueness => { :scope => :asset_id, :case_sensitive => false }

  attr_accessible :asset_id, :style, :width, :height, :asset

  def self.from_file(file, style = :original)
    if file
      geometry = Paperclip::Geometry.from_file(file)
      AssetGeometry.new(:width  => geometry.width,
                        :height => geometry.height,
                        :style  => style.to_s) if geometry
    end
  end

  def generate
    @geometry ||= Paperclip::Geometry.new(self.width, self.height)
  end
end
