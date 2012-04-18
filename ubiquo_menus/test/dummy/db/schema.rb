# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120308093118) do

  create_table "asset_areas", :force => true do |t|
    t.integer  "asset_id"
    t.string   "style"
    t.integer  "top"
    t.integer  "left"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "asset_areas", ["asset_id"], :name => "index_asset_areas_on_asset_id"

  create_table "asset_geometries", :force => true do |t|
    t.integer  "asset_id"
    t.string   "style"
    t.float    "width"
    t.float    "height"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "asset_geometries", ["asset_id"], :name => "index_asset_geometries_on_asset_id"

  create_table "asset_relations", :force => true do |t|
    t.integer  "asset_id"
    t.string   "name"
    t.integer  "related_object_id"
    t.string   "related_object_type"
    t.integer  "position"
    t.string   "field_name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "asset_relations", ["asset_id"], :name => "index_asset_relations_on_asset_id"
  add_index "asset_relations", ["related_object_type", "related_object_id"], :name => "by_related_object_typ_and_id"

  create_table "asset_types", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assets", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "asset_type_id"
    t.string   "resource_file_name"
    t.integer  "resource_file_size"
    t.string   "resource_content_type"
    t.string   "type"
    t.boolean  "is_protected"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "keep_backup",           :default => true
  end

  add_index "assets", ["asset_type_id"], :name => "index_assets_on_asset_type_id"

  create_table "blocks", :force => true do |t|
    t.string   "block_type"
    t.integer  "page_id"
    t.integer  "shared_id"
    t.boolean  "is_shared",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "blocks", ["block_type"], :name => "index_blocks_on_block_type"
  add_index "blocks", ["page_id"], :name => "index_blocks_on_page_id"

  create_table "menu_items", :force => true do |t|
    t.integer  "parent_id"
    t.string   "caption"
    t.string   "url"
    t.text     "description"
    t.boolean  "is_linkable", :default => false
    t.boolean  "is_active",   :default => true
    t.integer  "position"
    t.integer  "menu_id"
    t.integer  "page_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "key"
  end

  create_table "menus", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "url_name"
    t.string   "key"
    t.string   "page_template"
    t.boolean  "is_modified"
    t.boolean  "is_static"
    t.integer  "published_id"
    t.integer  "parent_id"
    t.string   "meta_title"
    t.text     "meta_keywords"
    t.text     "meta_description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "pages", ["page_template"], :name => "index_pages_on_page_template"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["published_id"], :name => "index_pages_on_published_id"
  add_index "pages", ["url_name"], :name => "index_pages_on_url_name"

  create_table "ubiquo_settings", :force => true do |t|
    t.string   "key"
    t.string   "context"
    t.string   "type"
    t.text     "value"
    t.text     "allowed_values"
    t.text     "options"
    t.string   "is_inherited"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "widgets", :force => true do |t|
    t.string   "name"
    t.text     "options"
    t.integer  "block_id"
    t.integer  "position"
    t.string   "type"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "version",    :default => 0
  end

  add_index "widgets", ["block_id"], :name => "index_widgets_on_block_id"
  add_index "widgets", ["type"], :name => "index_widgets_on_type"

end
