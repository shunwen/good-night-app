class Sleep < ApplicationRecord
  belongs_to :user

  validates :started_at_raw, presence: true
  validate :started_at_before_stopped_at

  before_save :set_started_at_utc
  before_save :set_duration

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
