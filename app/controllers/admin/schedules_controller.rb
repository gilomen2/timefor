class Admin::SchedulesController < ApplicationController
  def index
    @user = current_user
    @contacts = policy_scope(Contact)
    @schedules = policy_scope(Schedule)
    @schedule = Schedule.new
    @frequency = Frequency.new
    @timepicker = true
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
    @occurence = Occurence.new(schedule: @schedule, time: @frequency.first_occurence)
    @schedule.last_occurence_date = @frequency.first_occurence
    authorize @schedule

    respond_to do |format|
      if @schedule.save && @frequency.save && @occurence.save
        format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
        format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
        format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
        @occurence.make_summit_request
      else
        flash[:error] = "There was a problem saving the schedule. Please try again."
      end
    end

  end

  def edit
    @schedule = Schedule.find(params[:id])
    @frequency = @schedule.frequency
    @user = current_user
    authorize @schedule
  end

  def update
    @schedule = Schedule.find(params[:id])
    @frequency = @schedule.frequency
    authorize @schedule
    if @schedule.update_attributes(schedule_params) && @frequency.update_attributes(frequency_params)
      redirect_to admin_schedules_path
      flash.now[:notice] = "Schedule successfully edited."
    else
      redirect_to admin_schedules_path
      flash.now[:error] = "There was a problem editing the Schedule. Please try again."
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    @frequency = @schedule.frequency
    authorize @schedule
    if @schedule.destroy
      @frequency.destroy
      flash.now[:notice] = "Schedule successfully deleted."
    else
      flash.now[:error] = "There was a problem deleting the Schedule. Please try again."
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
      params.require(:frequency).permit(:schedule_id, :start_date, :timezone, :time, :repeat, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    end



end
