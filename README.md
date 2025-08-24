# Good Night App

## API Test Page

Clone repo, set up database, start Rails server, then test APIs at 
https://localhost:3000/api_test/ (created with Claude Code,
not all APIs are supported here).

## Assumptions

For simplicity:

- No user registration or login features. Create users through the API test page or Rails console: `user = User.create!(name: "your_name")`.
- Authentication uses cookie-based sessions. Set `user_id=your_user_id` via the API test page or browser console: `document.cookie = "user_id=your_user_id"`. Same mechanism works for both HTML and JSON API requests.
- Users have only two attributes: `id` and `name`.
- HTML views from scaffolding remain for easier manual testing.

## Requirements

- For API routes, see `config/routes.rb`. Most APIs follow Rails conventions. Check `schema.rb` for model attributes.
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
- Set cookie `user_id` to identify the current user. Routes under `users` namespace operate on the current user implicitly.
- **[Requirement 1]** Track sleep with `started_at_raw` (bedtime) and `stopped_at_raw` (wake time). Both accept datetime strings with timezone info (e.g. `2024-01-01T23:00:00+09:00`). App converts to UTC and calculates `duration`. Only `started_at_raw` is required - missing `stopped_at_raw` means user is still sleeping.
    - Any `Date.parse` compatible string works.
    - Raw data stored for future timezone features.
- **[Requirement 2]** Users can follow/unfollow others. Self-following not allowed. No duplicate follows.
- **[Requirement 3]** With `user_id` cookie set, visit `/users/following_others/prev_week_sleeps` via JSON API or HTML. Previous week defined by `Time.current.prev_week.all_week`.

## Performance Considerations

### Basics
1. **Indexes**
    - Sleeps table: `user_id` and `started_at_utc` for user/date filtering
    - Follows table: `follower_id` and `followed_id` for relationship lookups
2. **Pagination** - More users means larger prev_week_sleeps responses. Paginate to reduce memory usage.
3. **Follow limits** - Set upper limit per user (e.g. 5000 like X) to prevent excessive growth.
4. **Counter caches** - APIs don't need counts currently. If added later, use counter caches for expensive COUNT queries.
5. **Caching** - Cache prev_week_sleeps results per user for 5+ minutes, or implement cache invalidation based on follows' sleep updates.
6. **Response compression**

### Advanced
1. **Data Volume** - 1 sleep record ≈ 120 bytes. 100 years per user ≈ 4MB. Global scale (8B users) ≈ 32PB over 100 years.
2. **Archival** - Archive old data to cheaper storage. Keep recent data hot, sync historical data to user devices.
3. **Traffic Distribution** - Global usage spreads requests across 24 hours due to time zones (though not evenly).
4. **Scaling Example** - To handle 25k req/s (number based on 2011 Japan 
   twitter incident): need ~100 servers (assuming 250 req/s per Rails server). 
   Sleep creation at 1kB/req = 25MB/s, well below SSD write speeds (6-12GB/s).
5. **Database Scaling** - Use read replicas for read traffic distribution, sharding for write traffic distribution when Ruby/database becomes the bottleneck.
6. **Pregeneration** - After users update sleeps, enqueue background jobs to
   pregenerate prev_week_sleeps data for followers. Read from the
   pregenerated data.
