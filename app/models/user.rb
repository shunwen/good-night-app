class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  after_destroy_commit do
    ShardRecord.connected_to_all_shards(role: :writing) do
      ShardedFollow.where(followed_id: id).delete_all
    end

    follows.sharded.delete_all
  end

  def follows
    @follows ||= Follow.new(self)
  end

  def following_others = follows.following_others

  def following?(user)
    follows.following?(followed_id: user.id)
  end

  def follow(user)
    unless self == user || following?(user) || follows.count >= Follow::FOLLOWS_LIMIT
      follows.create!(followed_id: user.id)
    end
  end

  def unfollow(user)
    follows.destroy!(followed_id: user.id)
  end
end
