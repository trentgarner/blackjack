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

ActiveRecord::Schema[7.2].define(version: 2025_10_16_011408) do
  create_table "cards", force: :cascade do |t|
    t.string "rank"
    t.string "suit"
    t.integer "round_id", null: false
    t.integer "player_id", null: false
    t.integer "position"
    t.boolean "in_deck"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_cards_on_player_id"
    t.index ["round_id"], name: "index_cards_on_round_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.decimal "balance"
    t.boolean "is_dealer"
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "status"
    t.decimal "bet"
    t.string "outcome_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_rounds_on_game_id"
  end

  add_foreign_key "cards", "players"
  add_foreign_key "cards", "rounds"
  add_foreign_key "players", "games"
  add_foreign_key "rounds", "games"
end
