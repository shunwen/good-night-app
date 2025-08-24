class CreateSleeps < ActiveRecord::Migration[8.0]
  def change
    create_table :sleeps do |t|
      t.string :started_at_raw, null: false
      t.datetime :started_at_utc, null: false
      t.string :stopped_at_raw
      t.integer :duration
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :sleeps, [:user_id, :started_at_utc, :duration]
  end
end
