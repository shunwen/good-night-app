class ArchiveOldSleepsJob < ApplicationJob
  queue_as :default

  def perform
    Sleep.archive_old_sleeps!
  end
end
