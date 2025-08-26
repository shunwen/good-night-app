class Users::SleepsController < ApplicationController
  before_action :set_sleep, only: %i[ show edit update destroy ]
  before_action :forbid_update_old_sleep, only: %i[ update ]

  # GET /sleeps or /sleeps.json
  def index
    @sleeps = Sleep.where_across_partitions(user: Current.user)
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
    if @sleep.old?
      redirect_to(
        users_sleep_path(@sleep),
        alert: "Cannot edit old sleep records.")
    end
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
      @sleep =
        begin
          sleep = Sleep.find_across_partitions(params[:id])
          sleep.user == Current.user ? sleep : head(:not_found)
        end
    end

    def forbid_update_old_sleep
      head :forbidden if @sleep.old?
    end

    # Only allow a list of trusted parameters through.
    def sleep_params
      params.expect(sleep: [ :started_at_raw, :stopped_at_raw ])
    end
end
