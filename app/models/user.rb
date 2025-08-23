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

  validates_presence_of :name
  validates_uniqueness_of :name
end
