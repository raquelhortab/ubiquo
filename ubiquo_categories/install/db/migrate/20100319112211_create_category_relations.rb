class CreateCategoryRelations < ActiveRecord::Migration
  def self.up
    uhook_create_category_relations_table do |t|
      t.integer :category_id
      t.integer :related_object_id
      t.string :related_object_type
      t.integer :position
      t.string :attr_name
      t.timestamps
    end

    add_index(:category_relations, :category_id)
    add_index(:category_relations, :related_object_type)
    add_index(:category_relations,  [:related_object_id, :related_object_type], :name => "category_relations_on_related_object_id_and_related_object_type")
  end

  def self.down
    drop_table :category_relations
  end
end
