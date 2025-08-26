class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table "follows", force: :cascade do |t|
      t.integer "follower_id", null: false
      t.integer "followed_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "followed_id" ], name: "index_follows_on_followed_id"
      t.index [ "follower_id", "followed_id" ], name: "index_follows_on_follower_id_and_followed_id_unique", unique: true
      t.index [ "follower_id" ], name: "index_follows_on_follower_id"
    end
  end
end
