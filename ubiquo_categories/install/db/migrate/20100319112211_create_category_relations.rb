class CreateCategoryRelations < ActiveRecord::Migration
  def self.up
    create_table :category_relations do |t|
      t.integer :category_id
      t.integer :related_object_id
      t.string :related_object_type
      t.timestamps

      t.index :category_id
      t.index [:related_object_id, :related_object_type]
    end
  end

  def self.down
    drop_table :category_relations
  end
end
