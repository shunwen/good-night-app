class ApiTestController < ApplicationController
  allow_unauthenticated_access
  
  def index
    @endpoints = [
      {
        name: "Users#create",
        method: "POST",
        url: "/users",
        description: "Create a new user",
        sample_payload: { user: { name: "Test User" } }
      }
    ]
  end

  def impersonate
    user_id = params[:user_id]
    cookies[:user_id] = user_id
    
    begin
      @user = User.find(user_id)
      @sleeps_count = @user.sleeps.count
      @following_count = @user.following_others.count
      @status = :success
    rescue ActiveRecord::RecordNotFound
      @user = nil
      @status = :not_found
    end

    render turbo_stream: turbo_stream.update("auth-status", 
      partial: "auth_status", 
      locals: { user: @user, user_id: user_id, sleeps_count: @sleeps_count, following_count: @following_count, status: @status }
    )
  end

  def clear_auth
    cookies.delete(:user_id)
    
    render turbo_stream: turbo_stream.update("auth-status", 
      partial: "auth_status", 
      locals: { user: nil, user_id: nil, sleeps_count: 0, following_count: 0, status: :cleared }
    )
  end
end