class CreateCategorySets < ActiveRecord::Migration
  def self.up
    create_table :category_sets do |t|
      t.string :name
      t.string :key
      
      t.timestamps

      t.index :key
    end
  end

  def self.down
    drop_table :category_sets
  end
end
