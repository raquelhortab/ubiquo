class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :translatable => true do |t|
      t.string :name
      t.text :description
      t.integer :category_set_id
      
      t.timestamps

      t.index :category_set_id
    end
  end

  def self.down
    drop_table :categories
  end
end
