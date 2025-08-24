class Sleep < ApplicationRecord
  belongs_to :user

  validates :started_at_raw, presence: true

  before_save :set_started_at_utc
  before_save :set_duration

  private

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
