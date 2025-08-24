class Users::FollowingOthersController < ApplicationController
  def index
    @following_others = Current.user.following_others
    
    respond_to do |format|
      format.html
      format.json { render json: @following_others }
    end
  end

  def create
    @other = User.find(params[:followed_id])

    respond_to do |format|
      if Current.user.follow(@other)
        format.html { redirect_to @other, notice: "You are now following #{@other.name}." }
        format.json { render json: @other, status: :created }
      else
        format.html { redirect_to @other, alert: "Unable to follow #{@other.name}." }
        format.json { render json: @other.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @other = Current.user.following_others.find(params[:id])

    respond_to do |format|
      if Current.user.unfollow(@other)
        format.html { redirect_to @other, notice: "You unfollowed #{@other.name}." }
        format.json { head :no_content }
      else
        format.html { redirect_to @other, alert: "Unable to unfollow #{@other.name}." }
        format.json { render json: { error: "Unable to unfollow #{@other.name}." }, status: :unprocessable_content }
      end
    end
  end
end
