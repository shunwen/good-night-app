class CreateSleeps < ActiveRecord::Migration[8.0]
  def change
    create_table "sleeps", id: false, force: :cascade do |t|
      t.integer "id", null: false, index: true, primary_key: true
      t.string "started_at_raw", null: false
      t.datetime "started_at_utc", null: false
      t.string "stopped_at_raw"
      t.integer "duration"
      t.integer "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "started_at_utc", "duration" ], name: "index_sleeps_on_started_at_utc_and_duration"
      t.index [ "user_id", "started_at_utc", "duration" ], name: "index_sleeps_on_user_id_and_started_at_utc_and_duration"
    end
  end
end
