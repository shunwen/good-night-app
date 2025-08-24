class User < ApplicationRecord
  has_many :follows,
           foreign_key: :followed_id,
           dependent: :destroy

  has_many :followers,
           through: :follows

  has_many :followings,
           class_name: "Follow",
           foreign_key: :follower_id,
           dependent: :destroy

  has_many :following_others,
           through: :followings,
           source: :followed

  has_many :sleeps, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  # Follow limit to prevent excessive data growth (like X's 5000 limit)
  FOLLOW_LIMIT = 5000

  def following?(user)
    followings.exists?(followed_id: user.id)
  end

  def follow(user)
    unless self == user || following?(user) || followings.count >= FOLLOW_LIMIT
      followings.create(followed: user)
    end
  end

  def unfollow(user)
    followings.find_by(followed_id: user.id)&.destroy
  end
end
