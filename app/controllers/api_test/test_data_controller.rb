class ApiTest::TestDataController < ApplicationController
  allow_unauthenticated_access

  def create
    # Parse parameters with defaults
    user_count = params[:user_count]&.to_i || 1000
    follows_per_user = params[:follows_per_user]&.to_i || 500
    sleeps_per_user = params[:sleeps_per_user]&.to_i || 300

    # Validate parameters
    if user_count < 1 || user_count > 10000
      return render json: { error: "user_count must be between 1 and 10000" }, status: :bad_request
    end
    
    if follows_per_user < 0 || follows_per_user > user_count
      return render json: { error: "follows_per_user must be between 0 and user_count" }, status: :bad_request
    end
    
    if sleeps_per_user < 0 || sleeps_per_user > 1000
      return render json: { error: "sleeps_per_user must be between 0 and 1000" }, status: :bad_request
    end

    result = TestData.setup!(
      user_count: user_count,
      follows_per_user: follows_per_user,
      sleeps_per_user: sleeps_per_user
    )

    respond_to do |format|
      format.json do
        render json: {
          status: 'completed',
          users_created: result[:users_created],
          follows_created: result[:follows_created],
          sleep_records_created: result[:sleep_records_created],
          total_time_seconds: result[:total_time_seconds],
          parameters: {
            user_count: user_count,
            follows_per_user: follows_per_user,
            sleeps_per_user: sleeps_per_user
          }
        }
      end
    end
  end
end