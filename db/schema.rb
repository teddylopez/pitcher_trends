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

ActiveRecord::Schema.define(version: 2020_11_05_171138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "away_team_name"
    t.string "home_team_name"
    t.jsonb "details", default: {}
    t.jsonb "boxscore", default: {}
    t.string "starts_at"
    t.string "schedule_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "date_of_birth"
    t.integer "position"
    t.integer "bats"
    t.integer "throws"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plays", force: :cascade do |t|
    t.bigint "game_id"
    t.integer "batter_id"
    t.integer "pitcher_id"
    t.jsonb "pitch", default: {}
    t.string "pitch_type"
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "pitch_velocity"
    t.index ["batter_id"], name: "index_plays_on_batter_id"
    t.index ["game_id"], name: "index_plays_on_game_id"
    t.index ["pitcher_id"], name: "index_plays_on_pitcher_id"
  end

  create_table "stat_lines", force: :cascade do |t|
    t.jsonb "stats", default: {}
    t.bigint "game_id"
    t.bigint "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_stat_lines_on_game_id"
    t.index ["player_id"], name: "index_stat_lines_on_player_id"
  end

  add_foreign_key "plays", "players", column: "pitcher_id"
  add_foreign_key "stat_lines", "games"
  add_foreign_key "stat_lines", "players"
end
