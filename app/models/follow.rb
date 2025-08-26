class Follow
  FOLLOWS_LIMIT = 5000

  attr_reader :follower, :shard

  def initialize(follower)
    @follower = follower
    @shard = :"shard_#{follower.id.to_i % 2}"
  end

  def sharded
    ShardedFollow.where(follower_id: follower.id)
  end

  def with_shard(&block)
    ShardRecord.connected_to(shard:, &block)
  end

  def create!(followed_id:)
    raise ArgumentError, "Cannot follow self" if follower.id == followed_id

    with_shard do
      ShardedFollow.create!(follower_id: follower.id, followed_id:)
    end
  end

  def destroy!(followed_id:)
    with_shard do
      sharded.where(followed_id:).destroy_all
    end
  end

  def following?(followed_id:)
    with_shard do
      sharded.exists?(followed_id:)
    end
  end

  def followed_ids
    with_shard do
     sharded.pluck(:followed_id)
    end
  end

  def following_others
    @following_others ||= User.where(id: followed_ids)
  end

  def count
    with_shard do
      sharded.count
    end
  end
end
