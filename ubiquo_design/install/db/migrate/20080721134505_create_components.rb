class CreateComponents < ActiveRecord::Migration
  def self.up
    create_table :components do |t|
      t.text :options
      t.integer :component_type_id
      t.integer :block_id
      t.integer :position
      t.string :type
      t.string :name

      t.timestamps
    end
    add_index :components, :component_type_id
    add_index :components, :block_id
    add_index :components, :type
  end

  def self.down
    drop_table :components
  end
end
