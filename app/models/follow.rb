class Follow < ApplicationRecord
  belongs_to :follower,
             class_name: "User",
             inverse_of: :followings

  belongs_to :followed,
             class_name: "User",
             inverse_of: :follows

  validate :cannot_follow_self

  private

    def cannot_follow_self
      if follower_id == followed_id
        errors.add(:follower, "can't be the same as followed")
      end
    end
end
