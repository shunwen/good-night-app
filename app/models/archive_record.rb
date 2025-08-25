class ArchiveRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :archive, reading: :archive }
end
