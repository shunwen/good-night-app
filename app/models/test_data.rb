class TestData
  def self.setup!(user_count: 1000, follows_per_user: 500, sleeps_per_user: 300)
    Follow.delete_all
    Sleep.delete_all
    User.delete_all

    start_time = Time.current

    # Generate unique user names
    user_names = Set.new
    while user_names.count < user_count
      user_names << SecureRandom.alphanumeric(7)
    end

    # Prepare user parameters for bulk insert
    users_params = user_names.map do |name|
      { name: "User #{name}", created_at: start_time, updated_at: start_time }
    end

    # Insert users and get their IDs
    results = User.insert_all(users_params, returning: :id)
    user_ids = results.rows.flatten

    # Generate follow relationships based on follows_per_user parameter
    follows_params = []
    if follows_per_user > 0
      follows_params = user_ids.flat_map do |follower_id|
        # Calculate actual follow count (can't exceed available users)
        actual_follows_count = [follows_per_user, user_count - 1].min
        
        user_ids.excluding(follower_id).sample(actual_follows_count).map do |followed_id|
          {
            follower_id:,
            followed_id:,
            created_at: start_time + 1,
            updated_at: start_time + 1
          }
        end
      end
      Follow.insert_all(follows_params) if follows_params.any?
    end

    # Prepare sleep records for all users based on sleeps_per_user parameter
    sleep_params = []
    if sleeps_per_user > 0
      timezones = ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.strftime('%Z') }
      sleep_params = user_ids.flat_map do |user_id|
        generate_sleep_records_for_user(user_id, timezones.sample, start_time + 2, sleeps_per_user)
      end
      Sleep.insert_all(sleep_params) if sleep_params.any?
    end

    total_time = Time.current - start_time

    {
      users_created: user_count,
      follows_created: follows_params.count,
      sleep_records_created: sleep_params.count,
      total_time_seconds: total_time.round(2),
      user_ids: user_ids
    }
  end

  private

    def self.generate_sleep_records_for_user(user_id, tz, created_at, sleeps_per_user)
      # Adjust available days based on number of sleep records to be created
      # Use more days than records needed to ensure variety and avoid conflicts
      available_days_count = [sleeps_per_user * 1.5, 400].max
      available_days = (1..available_days_count).to_a
      selected_days = available_days.sample(sleeps_per_user)
      
      selected_days.map do |date_offset|
        date = Date.current.days_ago(date_offset)
        start_hour = [21, 22, 23, 0, 1, 2].sample
        start_minute = rand(60)
        started = date.beginning_of_day + start_hour.hours + start_minute.minutes
        duration = rand(18000..36000).seconds
        stopped = started + duration

        {
          user_id: user_id,
          started_at_raw: started.strftime("%Y-%m-%d %H:%M:%S #{tz}"),
          started_at_utc: started.utc,
          stopped_at_raw: stopped.strftime("%Y-%m-%d %H:%M:%S #{tz}"),
          duration: duration,
          created_at:,
          updated_at: created_at
        }
      end
    end
end
