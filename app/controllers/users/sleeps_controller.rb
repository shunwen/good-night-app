class Users::SleepsController < ApplicationController
  before_action :set_sleep, only: %i[ show edit update destroy ]

  # GET /sleeps or /sleeps.json
  def index
    @sleeps = Current.user.sleeps.order(started_at_utc: :desc)
  end

  # GET /sleeps/1 or /sleeps/1.json
  def show
  end

  # GET /sleeps/new
  def new
    @sleep = Current.user.sleeps.new
  end

  # GET /sleeps/1/edit
  def edit
  end

  # POST /sleeps or /sleeps.json
  def create
    @sleep = Current.user.sleeps.new(sleep_params)

    respond_to do |format|
      if @sleep.save
        format.html { redirect_to users_sleep_path(@sleep), notice: "Sleep was successfully created." }
        format.json { render :show, status: :created, location: users_sleep_url(@sleep) }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @sleep.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /sleeps/1 or /sleeps/1.json
  def update
    respond_to do |format|
      if @sleep.update(sleep_params)
        format.html { redirect_to users_sleep_path(@sleep), notice: "Sleep was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: users_sleep_url(@sleep) }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @sleep.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /sleeps/1 or /sleeps/1.json
  def destroy
    @sleep.destroy!

    respond_to do |format|
      format.html { redirect_to users_sleeps_path, notice: "Sleep was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_sleep
      @sleep = Current.user.sleeps.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sleep_params
      params.expect(sleep: [ :started_at_raw, :stopped_at_raw ])
    end
end
