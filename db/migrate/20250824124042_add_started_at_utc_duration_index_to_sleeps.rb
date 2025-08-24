class AddStartedAtUtcDurationIndexToSleeps < ActiveRecord::Migration[8.0]
  def change
    # Add index optimized for prev_week_sleeps multi-user time-range queries
    # This complements the existing ["user_id", "started_at_utc", "duration"] index
    # which is better for single-user queries like /users/sleeps
    # 
    # The prev_week_sleeps query pattern:
    # Sleep.joins(:user).where(user: followed_users)
    #   .where(started_at_utc: time_range).order(duration: :desc)
    # 
    # This index allows efficient:
    # 1. Time range filtering (started_at_utc)
    # 2. Pre-sorted results by duration DESC
    add_index :sleeps, [:started_at_utc, :duration], name: "index_sleeps_on_started_at_utc_and_duration"
  end
end
