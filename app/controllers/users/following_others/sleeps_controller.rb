class Users::FollowingOthers::SleepsController < ApplicationController
  def index
    @sleeps = Sleep.joins(:user)
                   .where(user: Current.user.following_others)
                   .includes(:user)
                   .order(started_at_utc: :desc)

    respond_to do |format|
      format.html
      format.json
    end
  end
end