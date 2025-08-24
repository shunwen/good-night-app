class TestData
  def self.setup!(user_count: 1000)
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

    follows_params = user_ids.flat_map do |follower_id|
      user_ids.excluding(follower_id).sample(user_count / 2).map do |followed_id|
        {
          follower_id:,
          followed_id:,
          created_at: start_time + 1,
          updated_at: start_time + 1
        }
      end
    end
    Follow.insert_all(follows_params)

    # Prepare sleep records for all users
    timezones = ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.strftime('%Z') }
    sleep_params = user_ids.flat_map do |user_id|
      generate_sleep_records_for_user(user_id, timezones.sample, start_time + 2)
    end

    # Insert all sleep records
    Sleep.insert_all(sleep_params)

    total_time = Time.current - start_time

    {
      users_created: user_count,
      sleep_records_created: sleep_params.count,
      total_time_seconds: total_time.round(2),
      user_ids: user_ids
    }
  end

  private

    def self.generate_sleep_records_for_user(user_id, tz, created_at)
      (1..400).to_a.sample(300).map do |date_offset|
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
