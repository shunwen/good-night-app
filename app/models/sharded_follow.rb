class ShardedFollow < ShardRecord
  self.table_name = "follows"

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Shard based on follower_id since most queries are follower-centric
  def self.shard_for_follower(follower_id)
    shard_for(follower_id)
  end

  # Create a follow relationship
  def self.create_follow!(follower_id, followed_id)
    with_shard(follower_id) do
      create!(follower_id:, followed_id:)
    end
  end

  # Remove a follow relationship
  def self.destroy_follow!(follower_id, followed_id)
    with_shard(follower_id) do
      where(follower_id:, followed_id:).destroy_all
    end
  end

  # Find follows for a specific follower
  def self.follows_for_follower(follower_id)
    with_shard(follower_id) do
      where(follower_id:)
    end
  end

  # Check if follower follows someone
  def self.following?(follower_id, followed_id)
    with_shard(follower_id) do
      exists?(follower_id:, followed_id:)
    end
  end

  # Get all followed user IDs for a follower
  def self.followed_ids_for(follower_id)
    with_shard(follower_id) do
      where(follower_id:).pluck(:followed_id)
    end
  end

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
