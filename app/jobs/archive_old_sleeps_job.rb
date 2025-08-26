class ArchiveOldSleepsJob < ApplicationJob
  queue_as :default

  def perform(rows = 1000)
    Sleep.archive_old_sleeps!(rows)
  end
end
