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

ActiveRecord::Schema[8.0].define(version: 2026_03_07_150517) do
  create_table "drivers", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "code"
    t.integer "number"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_drivers_on_external_id", unique: true
    t.index ["team_id"], name: "index_drivers_on_team_id"
  end

  create_table "invite_codes", force: :cascade do |t|
    t.string "code", null: false
    t.integer "max_uses", default: 1, null: false
    t.integer "uses_count", default: 0, null: false
    t.datetime "expires_at"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_invite_codes_on_code", unique: true
    t.index ["created_by_id"], name: "index_invite_codes_on_created_by_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "race_id", null: false
    t.string "session_type", null: false
    t.integer "position"
    t.integer "driver_id", null: false
    t.integer "points_earned", default: 0, null: false
    t.string "prediction_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_predictions_on_driver_id"
    t.index ["race_id"], name: "index_predictions_on_race_id"
    t.index ["user_id", "race_id", "session_type", "prediction_type", "position"], name: "idx_predictions_unique", unique: true
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "race_results", force: :cascade do |t|
    t.integer "race_id", null: false
    t.integer "driver_id", null: false
    t.string "session_type", null: false
    t.integer "position", null: false
    t.boolean "fastest_lap", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_race_results_on_driver_id"
    t.index ["race_id", "session_type", "driver_id"], name: "index_race_results_on_race_id_and_session_type_and_driver_id", unique: true
    t.index ["race_id", "session_type", "position"], name: "index_race_results_on_race_id_and_session_type_and_position", unique: true
    t.index ["race_id"], name: "index_race_results_on_race_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.integer "round", null: false
    t.string "circuit_name"
    t.string "circuit_country"
    t.datetime "race_date"
    t.datetime "quali_date"
    t.datetime "sprint_date"
    t.boolean "has_sprint", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.integer "season_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "circuit_image_url"
    t.datetime "slack_posted_at"
    t.index ["external_id"], name: "index_races_on_external_id", unique: true
    t.index ["season_id", "round"], name: "index_races_on_season_id_and_round", unique: true
    t.index ["season_id"], name: "index_races_on_season_id"
  end

  create_table "season_predictions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "season_id", null: false
    t.integer "drivers_champion_id"
    t.integer "constructors_champion_id"
    t.integer "points_earned", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constructors_champion_id"], name: "index_season_predictions_on_constructors_champion_id"
    t.index ["drivers_champion_id"], name: "index_season_predictions_on_drivers_champion_id"
    t.index ["season_id"], name: "index_season_predictions_on_season_id"
    t.index ["user_id", "season_id"], name: "index_season_predictions_on_user_id_and_season_id", unique: true
    t.index ["user_id"], name: "index_season_predictions_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "year", null: false
    t.boolean "current", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_seasons_on_year", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_teams_on_external_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.boolean "admin", default: false, null: false
    t.integer "total_points", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_reminders", default: true, null: false
    t.string "timezone", default: "America/Denver", null: false
    t.string "time_format", default: "24h", null: false
    t.string "theme", default: "default", null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "drivers", "teams"
  add_foreign_key "invite_codes", "users", column: "created_by_id"
  add_foreign_key "predictions", "drivers"
  add_foreign_key "predictions", "races"
  add_foreign_key "predictions", "users"
  add_foreign_key "race_results", "drivers"
  add_foreign_key "race_results", "races"
  add_foreign_key "races", "seasons"
  add_foreign_key "season_predictions", "drivers", column: "drivers_champion_id"
  add_foreign_key "season_predictions", "seasons"
  add_foreign_key "season_predictions", "teams", column: "constructors_champion_id"
  add_foreign_key "season_predictions", "users"
  add_foreign_key "sessions", "users"
end
