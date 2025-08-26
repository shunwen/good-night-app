class ShardRecord < ApplicationRecord
  self.abstract_class = true

  connects_to shards: {
    shard_0: { writing: :shard_0, reading: :shard_0 },
    shard_1: { writing: :shard_1, reading: :shard_1 }
  }

  # Shard routing based on user_id
  def self.shard_for(user_id)
    "shard_#{user_id.to_i % 2}".to_sym
  end

  # Connect to appropriate shard for writing
  def self.with_shard(user_id, &block)
    shard = shard_for(user_id)
    connected_to(database: { writing: shard, reading: shard }, &block)
  end
end
