class ShardedFollow < ShardRecord
  self.table_name = "follows"

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates_uniqueness_of :followed_id, scope: [ :follower_id ]
  validate :cannot_follow_self

  private

    def cannot_follow_self
      if follower_id == followed_id
        errors.add(:follower, "can't be the same as followed")
      end
    end
end
