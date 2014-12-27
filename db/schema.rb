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

ActiveRecord::Schema.define(version: 20141227043927) do

  create_table "artists", force: true do |t|
    t.string   "name"
    t.string   "nationality"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artworks", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "completion_date"
    t.string   "dimensions"
    t.string   "gallery_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artist_id"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.text     "description"
    t.integer  "user_id"
  end

  add_index "artworks", ["artist_id"], name: "index_artworks_on_artist_id"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "auth_token"
    t.string   "alias"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

end
