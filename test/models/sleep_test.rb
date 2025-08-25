require "test_helper"

class SleepTest < ActiveSupport::TestCase
  test "should calculate duration when stopped_at_raw is present" do
    sleep = Sleep.new(
      user: users(:one),
      started_at_raw: "2025-01-01 22:00:00",
      stopped_at_raw: "2025-01-02 06:00:00"
    )

    sleep.save!

    assert_equal 8.hours, sleep.duration
  end

  test "should not set duration when stopped_at_raw is blank" do
    sleep = Sleep.new(
      user: users(:one),
      started_at_raw: "2025-01-01 22:00:00",
      stopped_at_raw: nil
    )

    sleep.save!

    assert_nil sleep.duration
  end

  test "should update duration when stopped_at_raw changes" do
    sleep = sleeps(:one)
    original_duration = sleep.duration
    stopped_at_raw = sleep.started_at_utc + original_duration + 1.hour

    sleep.update!(stopped_at_raw:)

    assert_equal sleep.duration, original_duration + 1.hour
  end

  test "should require started_at presence" do
    sleep = Sleep.new(user: users(:one))

    assert_not sleep.valid?
    assert_includes sleep.errors[:started_at_raw], "can't be blank"
  end

  test "should belong to user" do
    sleep = Sleep.new(started_at_raw: "2025-01-01 22:00:00")

    assert_not sleep.valid?
    assert_includes sleep.errors[:user], "must exist"
  end

  test "should validate stopped_at_raw is after started_at_raw" do
    sleep = Sleep.new(
      user: users(:one),
      started_at_raw: "2025-01-01 22:00:00",
      stopped_at_raw: "2025-01-01 20:00:00"
    )

    assert_not sleep.valid?
    assert_includes sleep.errors[:stopped_at_raw], "must be after started_at_raw"
  end

  test "should archive old sleeps to archive database" do
    # Create old sleep (before previous week)
    old_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 2.weeks.ago.iso8601,
      stopped_at_raw: (2.weeks.ago + 8.hours).iso8601
    )
    
    # Create recent sleep (within previous week)
    recent_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 3.days.ago.iso8601,
      stopped_at_raw: (3.days.ago + 7.hours).iso8601
    )

    old_count = Sleep.old.count

    assert_difference 'Sleep.count', -old_count do
      assert_difference 'Archive::Sleep.count', old_count do
        Sleep.archive_old_sleeps!
      end
    end

    assert Sleep.exists?(recent_sleep.id)
    assert_not Archive::Sleep.exists?(recent_sleep.id)
    assert_not Sleep.exists?(old_sleep.id)
    assert Archive::Sleep.exists?(old_sleep.id)
  end

  test "current scope should only return sleeps from previous week onwards" do
    # Create old sleep (before previous week)
    Sleep.create!(
      user: users(:one),
      started_at_raw: 2.weeks.ago.iso8601,
      stopped_at_raw: (2.weeks.ago + 8.hours).iso8601
    )
    
    # Create recent sleep (within previous week range)
    recent_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 3.days.ago.iso8601,
      stopped_at_raw: (3.days.ago + 7.hours).iso8601
    )

    assert_includes Sleep.current, recent_sleep
    assert_equal 1, Sleep.current.where(user: users(:one)).count
  end

  test "find_across_partitions should find sleep in primary database" do
    sleep = sleeps(:one)
    found_sleep = Sleep.find_across_partitions(sleep.id)
    assert_equal sleep.id, found_sleep.id
  end

  test "find_across_partitions should find sleep in archive database" do
    # Create and archive a sleep
    old_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 2.weeks.ago.iso8601,
      stopped_at_raw: (2.weeks.ago + 8.hours).iso8601
    )
    Sleep.archive_old_sleeps!
    
    found_sleep = Sleep.find_across_partitions(old_sleep.id)
    assert found_sleep.is_a?(Archive::Sleep)
  end

  test "where_across_partitions should return results from both databases" do
    # Create old sleep and archive it
    old = Sleep.create!(
      user: users(:one),
      started_at_raw: 2.weeks.ago.iso8601,
      stopped_at_raw: (2.weeks.ago + 8.hours).iso8601
    )
    
    # Create recent sleep
    recent = Sleep.create!(
      user: users(:one),
      started_at_raw: 3.days.ago.iso8601,
      stopped_at_raw: (3.days.ago + 7.hours).iso8601
    )

    count = users(:one).sleeps.count
    Sleep.archive_old_sleeps!
    
    # Search across partitions
    all_user_sleeps = Sleep.where_across_partitions(user_id: users(:one).id)
    
    assert_equal count, all_user_sleeps.length
    assert_includes all_user_sleeps.map(&:class), Sleep
    assert_includes all_user_sleeps.map(&:class), Archive::Sleep
  end

  test "where_across_partitions should sort results by started_at_utc" do
    # Create sleeps with different timestamps
    middle_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 1.week.ago.iso8601,
      stopped_at_raw: (1.week.ago + 8.hours).iso8601
    )
    
    old_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 3.weeks.ago.iso8601,
      stopped_at_raw: (3.weeks.ago + 8.hours).iso8601
    )
    
    recent_sleep = Sleep.create!(
      user: users(:one),
      started_at_raw: 2.days.ago.iso8601,
      stopped_at_raw: (2.days.ago + 8.hours).iso8601
    )

    count = users(:one).sleeps.count
    Sleep.archive_old_sleeps!
    
    # Search across partitions
    all_sleeps = Sleep.where_across_partitions(user_id: users(:one).id)
    
    # Should be sorted by started_at_utc (oldest first)
    assert_equal count, all_sleeps.length
    assert all_sleeps[0].started_at_utc < all_sleeps[1].started_at_utc
    assert all_sleeps[1].started_at_utc < all_sleeps[2].started_at_utc
  end
end
