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
    authorize @schedule

    puts "@frequency.format_time:" + @frequency.format_time

    @occurences = build_occurences(@schedule, @frequency)

    @schedule.last_occurence_date = get_last_occurence_date(@occurences)

    if @occurences.each(&:save!)
      respond_to do |format|
        if @schedule.save && @frequency.save
          format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
          format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
          format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
        else
          flash[:error] = "There was a problem saving the schedule. Please try again."
        end
      end
    else
      flash[:error] = "There was a problem saving the schedule. Please try again."
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

    def build_occurences(schedule, frequency)
      occurence_array = Montrose.every(:week).on(frequency.repeat_days).at(frequency.format_time).starts(frequency.start_date).take(1)
      a = []
      occurence_array.each do |occurence|
        a << Occurence.new(time: occurence.utc, schedule: schedule)
      end
      a
    end

    def get_last_occurence_date(occurences)
      last_occurence = occurences.sort_by(&:time).last
      last_occurence.time.to_date
    end

end
