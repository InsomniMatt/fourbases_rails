# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_02_225640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "at_bats", force: :cascade do |t|
    t.bigint "pitcher_id"
    t.bigint "batter_id"
    t.bigint "game_id"
    t.boolean "runner_first"
    t.boolean "runner_second"
    t.boolean "runner_third"
    t.integer "outs"
    t.integer "inning"
    t.string "inning_half"
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "at_bat_index"
    t.integer "team_id"
    t.integer "defense_team_id"
    t.index ["batter_id"], name: "index_at_bats_on_batter_id"
    t.index ["defense_team_id"], name: "index_at_bats_on_defense_team_id"
    t.index ["game_id"], name: "index_at_bats_on_game_id"
    t.index ["inning"], name: "index_at_bats_on_inning"
    t.index ["outs"], name: "index_at_bats_on_outs"
    t.index ["pitcher_id"], name: "index_at_bats_on_pitcher_id"
    t.index ["result"], name: "index_at_bats_on_result"
    t.index ["team_id"], name: "index_at_bats_on_team_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "home_team_id"
    t.bigint "away_team_id"
    t.integer "home_score"
    t.integer "away_score"
    t.datetime "game_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_games_on_away_team_id"
    t.index ["game_time"], name: "index_games_on_game_time"
    t.index ["home_team_id"], name: "index_games_on_home_team_id"
  end

  create_table "pitches", force: :cascade do |t|
    t.integer "pitch_type"
    t.float "velocity"
    t.integer "ball_count"
    t.integer "strike_count"
    t.float "x_location"
    t.float "y_location"
    t.float "x_movement"
    t.float "y_movement"
    t.bigint "at_bat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["at_bat_id"], name: "index_pitches_on_at_bat_id"
  end

  create_table "player_stats", force: :cascade do |t|
    t.bigint "player_id"
    t.string "avg"
    t.string "obp"
    t.string "slg"
    t.string "ops"
    t.integer "hits"
    t.integer "doubles"
    t.integer "triples"
    t.integer "home_runs"
    t.integer "walks"
    t.integer "strikeouts"
    t.integer "runs"
    t.integer "games"
    t.integer "at_bats"
    t.integer "rbi"
    t.integer "stolen_bases"
    t.integer "caught_stealing"
    t.integer "plate_appearances"
    t.integer "sac_fly"
    t.integer "sacrifices"
    t.integer "hbp"
    t.integer "gidp"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_player_stats_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "position"
    t.integer "team_id"
    t.integer "jersey_number"
    t.string "throw_arm"
    t.string "bat_arm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_on_name"
    t.index ["position"], name: "index_players_on_position"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "city"
    t.string "name"
    t.string "league"
    t.string "division"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "at_bats", "games"
  add_foreign_key "at_bats", "players", column: "batter_id"
  add_foreign_key "at_bats", "players", column: "pitcher_id"
  add_foreign_key "games", "teams", column: "away_team_id"
  add_foreign_key "games", "teams", column: "home_team_id"
  add_foreign_key "pitches", "at_bats"
end
