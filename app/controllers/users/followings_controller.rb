class Users::FollowingsController < ApplicationController
  def index
    @followings = Current.user.following_others.includes(:sleeps)
    
    respond_to do |format|
      format.html
      format.json { render json: @followings }
    end
  end

  def create
    @user = User.find(params[:followed_id])
    @follow = Current.user.followings.build(followed: @user)

    respond_to do |format|
      if @follow.save
        format.html { redirect_to @user, notice: "You are now following #{@user.name}." }
        format.json { render json: @follow, status: :created }
      else
        format.html { redirect_to @user, alert: "Unable to follow #{@user.name}." }
        format.json { render json: @follow.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:followed_id])
    @follow = Current.user.followings.find_by(followed: @user)

    respond_to do |format|
      if @follow&.destroy
        format.html { redirect_to @user, notice: "You unfollowed #{@user.name}." }
        format.json { head :no_content }
      else
        format.html { redirect_to @user, alert: "Unable to unfollow #{@user.name}." }
        format.json { render json: { error: "Unable to unfollow #{@user.name}." }, status: :unprocessable_entity }
      end
    end
  end
end
