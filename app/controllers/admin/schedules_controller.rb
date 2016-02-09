class Admin::SchedulesController < ApplicationController
  def index
    @contacts = policy_scope(Contact)
    @schedules = Schedule.all
    @schedule = Schedule.new
  end

  def new
    @schedule = Schedule.new
    @user = current_user
  end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.user_id = current_user.id
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
        format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
        # added:
        format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
      else
        format.html { render action: 'new' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
        # added:
        format.js   { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    if @schedule.destroy
      flash[:notice] = "Schedule successfully deleted."
    else
      flash[:error] = "There was a problem deleting the Schedule. Please try again."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def schedule_params
    params.require(:schedule).permit(:contact_id, :message)
  end
end
