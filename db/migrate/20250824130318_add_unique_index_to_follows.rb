class AddUniqueIndexToFollows < ActiveRecord::Migration[8.0]
  def change
    # Add unique constraint at database level to prevent duplicate follows
    # This is more efficient than application-level validation checking
    # and provides true data integrity regardless of race conditions
    add_index :follows, [ :follower_id, :followed_id ],
              unique: true,
              name: "index_follows_on_follower_id_and_followed_id_unique"
  end
end
