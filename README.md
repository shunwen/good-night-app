# Good Night App

## API Test Page

- Clone repo
- Add master.key `echo c1b530bcd1d3fe4c0d7c99bff24cd1d6 > config/master.key`.
  *Just for demo*.
- Set up database `rails db:setup`
- Run migrations `rails db:migrate`
- Start Rails server `rails server`
- Test APIs at https://localhost:3000/api_test _(created with Claude Code,
  not all APIs are supported here)_. It doesn't refresh information
  automatically, manual refresh the page to keep things up to date.

## Assumptions

For simplicity:

- No user registration features. Create users through the API test page
  or Rails console: `user = User.create!(name: "your_name")`.
- Simple authentication base on encrypted user id in cookie. Use
  `POST /session` with payload `{"user_id": "your user id"}` to get the signed
  cookie. Use `DELETE /session` to sign out.
- Users have only two attributes: `id` and `name`.
- HTML views from scaffolding remain for easier manual testing.
- Basic "follow" functionality is implemented. Due to sharding, it takes extra
  steps to retrieve one's followers, some related features are removed.
- Additional operations are not automated, e.g. `ArchiveOldSleepsJob` needs
  further scheduling before going to production.

## API (vs. Requirements)

- For API routes, see `config/routes.rb`. Most APIs follow Rails conventions.
  Check `schema.rb` for model attributes.
  ```ruby
  namespace :users do
    resources :sleeps
    resources :following_others, only: [:index, :create, :destroy]
    
    namespace :following_others do
      resources :prev_week_sleeps, only: [:index]
    end
  end
  resources :users, only: [:index, :show, :new, :create, :destroy]
  ```
- To use JSON API, in request set header `Accept` = `application/json`
- To pass authentication, `POST /session` with payload `{"user_id": "your user 
id"}` to get the signed cookie. Routes under `users`
  namespace operate on the current user implicitly.
- **[Requirement 1]** Track sleep with `started_at_raw` (bedtime) and
  `stopped_at_raw` (wake time). Both accept datetime strings with timezone
  info (e.g. `2024-01-01T23:00:00+09:00`). App converts to UTC and calculates
  `duration`. 
    - Create: `POST /users/sleeps` with payload `{"started_at_raw": 
    "2024-01-01T23:00:00+09:00", "stopped_at_raw": "2024-01-02T07:00:00+09:00"}`
        - stopped_at_raw is optional
        - duration will be derived when both started and stopped are present
    - Read: `GET /users/sleeps` for index and `GET /users/sleeps/:id` for show
    - Update: `PATCH /users/sleeps/:id` with payload
      `{"stopped_at_raw": "2024-01-02T08:00:00+09:00"}`
    - Delete: `DELETE /users/sleeps/:id`
    - Old sleeps (sleeps stated at before previous week) cannot be updated
    - Any `Date.parse` compatible string works.
    - Raw data stored for future timezone features.
    - _Note: Can create future sleep_
- **[Requirement 2]** Users can follow/unfollow others. No self-following not
  allowed. No duplicate follows.
    - Create: `POST /users/following_others` with payload
      `{"followed_id": "id of the user to follow"}`
    - Update: N/A
    - Read: `GET /users/following_others`, `GET /users/following_others/:id`
    - Delete: `DELETE /users/following_others/:id`
- **[Requirement 3]** See the sleep records of a user's All following users' sleep
records. from the previous week
  - With `user_id` cookie set, 
    `GET /users/following_others/prev_week_sleeps` via JSON API or HTML.
  - Previous week defined by `Time.current.prev_week.all_week`.

## Performance Considerations

### For Concurrency

The goal is to shorten response time such that the server can handle more
concurrent requests.

- Indexes: improve query efficiency
    - Indexes on sleeps table's `started_at_utc` and `duration`
    - Indexes on follow table's `follower_id` and `followed_id`, and an unique
      index on both
- Pagination: limit data per request. On prev_week_sleeps API, which can
  return many records.
- Follow limits: prevent excessive follows per user, set a predictable upper
  bound
- Response compression: normally done by web server, but enabled here for demo
  purposes

### For Large Data Volume

The goal is to retrieve data efficiently even with large datasets. The data
size is not a concern as long as the stored information has its purpose.

Sleeps data is partitioned, Follows are sharded.

- Time-partitioned db for `sleeps`:
    - Move sleeps started before the previous week to a
      separate DB and read from it for other APIs.
        - Enqueue background job to move outdated data to this DB.
    - It's easier to loose the FK on `sleeps.user_id` for either option.
    - Smaller table size for previous week sleeps

- Sharding for `follows`:
    - Horizontal partitioning by `follower_id mod 2` across 2 shard databases
    - Implemented via `Follow` class that routes to appropriate shard
    - Each user's follow relationships stored in consistent shard based on their
      ID

### For Growing User Base

**Not sharding the users table**:
- Cross-user queries (following, sleep comparisons) would require
  cross-shard operations
- Scale with read replicas and caching instead

User-generated data (sleeps, follows) can be sharded while keeping users
centralized.

### Caching

Caching is not implemented. Caching would require corresponding mechanisms to
invalidate cache. I'm out of time here.

### Notes

1. **Data Volume** - 1 sleep record ≈ 120 bytes. 100 years per user ≈ 4MB.
   Global scale (8B users) ≈ 32PB over 100 years.
2. **Traffic Distribution** - Global usage spreads requests across 24 hours due
   to time zones (though not evenly).
3. **Scaling Example** - To handle 25k req/s (number based on 2011 Japan
   twitter incident): need ~100 servers (assuming 250 req/s per Rails server).
   Sleep creation at 1kB/req = 25MB/s, well below SSD write speeds (6-12GB/s).
