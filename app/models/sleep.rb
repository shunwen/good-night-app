class Sleep < ApplicationRecord
  belongs_to :user

  validates :started_at_raw, presence: true
  validate :started_at_before_stopped_at

  before_save :set_started_at_utc
  before_save :set_duration

  # Scope for current sleeps (from previous week onwards)
  scope :current, -> { where(started_at_utc: Time.current.prev_week..) }
  scope :old, -> { where(started_at_utc: ...Time.current.prev_week) }

  # Class method to find sleep across partitions
  def self.find_across_partitions(id)
    find_by(id: id) || Archive::Sleep.find(id)
  end

  # Class method to search across partitions by date range
  def self.where_across_partitions(conditions)
    current_results = where(conditions)
    archived_results = Archive::Sleep.where(conditions)

    # Combine results maintaining order by started_at_utc
    (current_results.to_a + archived_results.to_a).sort_by(&:started_at_utc)
  end

  # Method to archive old sleeps (before previous week)
  def self.archive_old_sleeps!
    old.find_each.map do |sleep|
      archived = Archive::Sleep.create!(sleep.attributes)
      sleep.destroy!
      [ sleep, archived ]
    end
  end

  private

    def started_at_before_stopped_at
      return unless stopped_at_raw.present?

      started_time = DateTime.parse(started_at_raw)
      stopped_time = DateTime.parse(stopped_at_raw)

      if started_time >= stopped_time
        errors.add(:stopped_at_raw, "must be after started_at_raw")
      end
    rescue Date::Error, ArgumentError
      errors.add(:base, "Invalid datetime format in started_at_raw or stopped_at_raw")
    end

    def set_started_at_utc
      self.started_at_utc = DateTime.parse(started_at_raw).utc
    end

    def set_duration
      self.duration =
        if stopped_at_raw?
          DateTime.parse(stopped_at_raw).to_i - started_at_utc.to_i
        end
    end
end
