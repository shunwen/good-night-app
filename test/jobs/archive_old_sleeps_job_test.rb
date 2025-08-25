require "test_helper"

class ArchiveOldSleepsJobTest < ActiveJob::TestCase
  test "should call Sleep.archive_old_sleeps!" do
    Sleep.stubs(:archive_old_sleeps!).once
    ArchiveOldSleepsJob.perform_now
  end
end
