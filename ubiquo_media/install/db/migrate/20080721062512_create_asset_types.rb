class CreateAssetTypes < ActiveRecord::Migration
  def self.up
    create_table :asset_types do |t|
      t.string :name
      t.string :key

      t.timestamps
    end

    %w{video doc audio other image flash}.each do |key|
      AssetType.create!({:key => key, :name => key.capitalize})
    end
  end

  def self.down
    drop_table :asset_types
  end
end
