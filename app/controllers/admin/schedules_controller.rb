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
    @frequency.start_datetime = @frequency.format_datetime_utc
    @occurence = Occurence.new(schedule: @schedule, time: @frequency.first_occurence)
    @schedule.last_occurence_datetime = @frequency.first_occurence.in_time_zone(@frequency.timezone)
    authorize @schedule

    respond_to do |format|
      if @schedule.save && @frequency.save && @occurence.save
        format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
        format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
        format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
        @occurence.create_scheduled_call
      else
        flash[:error] = "There was a problem saving the schedule. Please try again."
      end
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
      params.require(:frequency).permit(:schedule_id, :start_datetime_date, :start_datetime_time, :timezone, :repeat, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    end

end
