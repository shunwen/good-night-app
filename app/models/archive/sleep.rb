module Archive
  class Sleep < ArchiveRecord
    self.table_name = "sleeps"

    belongs_to :user, required: true

    def old? = true
  end
end
