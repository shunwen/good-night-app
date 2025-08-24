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
end
