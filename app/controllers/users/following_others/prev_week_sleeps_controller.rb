class Users::FollowingOthers::PrevWeekSleepsController < ApplicationController
  def index
    # Pagination parameters
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 50
    offset = (page - 1) * per_page

    # Fetch one extra record to determine if there are more pages
    sleeps_with_extra =
      Sleep.joins(:user)
        .where(user: Current.user.following_others)
        .where(started_at_utc: Time.current.prev_week.all_week)
        .includes(:user)
        .order(duration: :desc)
        .limit(per_page + 1)
        .offset(offset)
        .to_a

    # Check if there are more records and trim to requested page size
    @has_next_page = sleeps_with_extra.size > per_page
    @sleeps = @has_next_page ? sleeps_with_extra[0, per_page] : sleeps_with_extra
    
    # Pagination metadata for JBuilder
    @pagination = {
      current_page: page,
      per_page: per_page,
      has_next_page: @has_next_page
    }

    respond_to do |format|
      format.html
      format.json
    end
  end
end
