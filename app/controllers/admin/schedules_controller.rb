class Admin::SchedulesController < ApplicationController
  def index
    @user = current_user
    @contacts = policy_scope(Contact)
    @schedules = policy_scope(Schedule)
    @schedule = Schedule.new
    @frequency = Frequency.new
    authorize Schedule
  end

  def new
    @schedule = Schedule.new
    @user = current_user
    authorize @schedule
  end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.user_id = current_user.id
    @frequency = Frequency.new(frequency_params)
    @frequency.schedule = @schedule
    authorize @schedule
    respond_to do |format|
      if @schedule.save && @frequency.save
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
    @schedule = Schedule.find(params[:id])
    @user = current_user
    authorize @schedule
  end

  def update
    @schedule = Schedule.find(params[:id])
    authorize @schedule
    if @schedule.update_attributes(schedule_params)
      redirect_to admin_schedules_path
      flash[:notice] = "Schedule successfully edited."
    else
      redirect_to admin_schedules_path
      flash[:error] = "There was a problem editing the Schedule. Please try again."
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    authorize @schedule
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

  def frequency_params
    params.require(:frequency).permit(:schedule_id, :start_date)
  end
end
