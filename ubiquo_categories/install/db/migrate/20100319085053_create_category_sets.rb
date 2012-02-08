class CreateCategorySets < ActiveRecord::Migration
  def self.up
    create_table :category_sets do |t|
      t.string :name
      t.string :key
      t.boolean :is_editable

      t.timestamps
    end

    add_index(:category_sets, :key)
  end

  def self.down
    drop_table :category_sets
  end
end
