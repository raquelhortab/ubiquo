class CreateActivityInfos < ActiveRecord::Migration
  def self.up
    create_table :activity_infos do |t|
      t.integer :ubiquo_user_id, :index => true
      t.string :controller, :index => true
      t.string :action, :index => true
      t.string :status, :index => true
      t.text :info
      t.integer :related_object_id
      t.string :related_object_type

      t.timestamps

    end
    add_index :activity_infos, [:related_object_id, :related_object_type], :name => :index_activity_infos_on_related_object
  end

  def self.down
    drop_table :activity_infos
  end
end

