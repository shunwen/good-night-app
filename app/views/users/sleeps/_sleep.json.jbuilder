json.extract! sleep,
              :id, :started_at_raw,
              :started_at_utc,
              :stopped_at_raw,
              :duration,
              :user_id, :created_at, :updated_at
json.url users_sleep_url(sleep, format: :json)
