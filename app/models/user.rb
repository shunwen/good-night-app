class User < ApplicationRecord
  has_many :follows,
           foreign_key: :followed_id,
           dependent: :destroy

  has_many :followers,
           through: :follows

  has_many :followings,
           class_name: "Follow",
           foreign_key: :follower_id

  has_many :following_others,
           through: :followings,
           source: :followed

  has_many :sleeps, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def following?(user)
    following_others.include?(user)
  end

  def follow(user)
    following_others << user unless self == user || following?(user)
  end

  def unfollow(user)
    following_others.delete(user) if following?(user)
  end
end
