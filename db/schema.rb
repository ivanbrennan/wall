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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150912195248) do

  create_table "castles", force: :cascade do |t|
    t.string "name", limit: 32, null: false
  end

  create_table "forays", id: false, force: :cascade do |t|
    t.integer "castle_id",   limit: 4, null: false
    t.integer "wildling_id", limit: 4, null: false
  end

  add_index "forays", ["wildling_id", "castle_id"], name: "index_forays_on_wildling_id_and_castle_id", unique: true, using: :btree

  create_table "patrols", id: false, force: :cascade do |t|
    t.integer "castle_id", limit: 4, null: false
    t.integer "ranger_id", limit: 4, null: false
  end

  add_index "patrols", ["ranger_id", "castle_id"], name: "index_patrols_on_ranger_id_and_castle_id", unique: true, using: :btree

  create_table "rangers", force: :cascade do |t|
    t.string "name", limit: 32, null: false
  end

  create_table "wildlings", force: :cascade do |t|
    t.string "name", limit: 32, null: false
  end

end
