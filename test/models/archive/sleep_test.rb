require "test_helper"

class Archive::SleepTest < ActiveSupport::TestCase
  test "should connect to archive database" do
    assert_equal "archive", Archive::Sleep.connection_pool.db_config.name
  end
end
