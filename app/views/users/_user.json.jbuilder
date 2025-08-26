json.extract! user, :id, :name, :created_at, :updated_at
json.url user_url(user, format: :json)
json.sleeps_count user.sleeps.count
json.following_count user.following_others.count
