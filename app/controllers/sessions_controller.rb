class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create destroy ]

  def new
  end

  def create
    if @user = User.find_by(id: params[:user_id])
      cookies.signed.permanent[:user_id] = { value: @user.id.to_s }

      respond_to do |format|
        format.json { head :created }
        format.html { redirect_to root_path, notice: "Signed in successfully" }
      end
    else
      respond_to do |format|
        format.json { head :unauthorized }
        format.html { redirect_to new_session_path, alert: "User not found" }
      end
    end
  end

  def destroy
    cookies.delete(:user_id)

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to root_path, notice: "Signed out successfully" }
    end
  end
end
