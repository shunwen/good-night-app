class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create destroy ]

  def new
  end

  def create
    if @user = User.find_by(id: params[:user_id])
      cookies.signed.permanent[:user_id] = { value: @user.id.to_s }
      head :created
    else
      head :unauthorized
    end
  end

  def destroy
    cookies.delete(:user_id)
    head :ok
  end
end
