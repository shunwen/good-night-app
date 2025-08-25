class ApiTestController < ApplicationController
  allow_unauthenticated_access

  def index
    # Check if user is already authenticated
    if cookies[:user_id].present?
      user_id = cookies[:user_id]
      begin
        @user = User.find(user_id)
        @sleeps_count = @user.sleeps.count
        @following_count = @user.following_others.count
        @status = :success
      rescue ActiveRecord::RecordNotFound
        @user = nil
        @sleeps_count = 0
        @following_count = 0
        @status = :not_found
      end
    else
      @user = nil
      @sleeps_count = 0
      @following_count = 0
      @status = :cleared
    end

    # Set a default user ID for the impersonate form
    @default_user_id = User.first&.id
  end

end
