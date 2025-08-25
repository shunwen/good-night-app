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

ActiveRecord::Schema[8.0].define(version: 2025_08_25_151343) do
  create_table "sleeps", force: :cascade do |t|
    t.string "started_at_raw", null: false
    t.datetime "started_at_utc", null: false
    t.string "stopped_at_raw"
    t.integer "duration"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_sleeps_on_id"
    t.index ["started_at_utc", "duration"], name: "index_sleeps_on_started_at_utc_and_duration"
    t.index ["user_id", "started_at_utc", "duration"], name: "index_sleeps_on_user_id_and_started_at_utc_and_duration"
  end
end
