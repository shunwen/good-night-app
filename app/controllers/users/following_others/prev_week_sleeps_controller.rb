class Users::FollowingOthers::PrevWeekSleepsController < ApplicationController
  def index
    @sleeps =
      Sleep.joins(:user)
        .where(user: Current.user.following_others)
        .where(started_at_utc: Time.current.prev_week.all_week)
        .includes(:user)
        .order(duration: :desc)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
