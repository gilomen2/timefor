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
    @scheduled_call = ScheduledCall.new(schedule: @schedule, call_id: make_summit_request(@schedule))
    authorize @schedule
    if @scheduled_call.save
      respond_to do |format|
        if @schedule.save && @frequency.save
          format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
          format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
          format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
        else
          format.html { render action: 'new' }
          format.json { render json: @schedule.errors, status: :unprocessable_entity }
          format.js   { render json: @schedule.errors, status: :unprocessable_entity }
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
      flash[:notice] = "Schedule successfully edited."
    else
      redirect_to admin_schedules_path
      flash[:error] = "There was a problem editing the Schedule. Please try again."
    end
  end

  def destroy
    @schedule = Schedule.find(params[:id])
    @frequency = @schedule.frequency
    authorize @schedule
    if @schedule.destroy
      @frequency.destroy
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
      params.require(:frequency).permit(:schedule_id, :start_date, :timezone, :time, :repeat, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    end

    def make_summit_request(schedule)
      mySchedule = schedule
      user = schedule_user(mySchedule)
      summit_url = 'https://api.us1.corvisa.io/call/schedule'
      # summit_url = 'http://requestb.in/1drt0xe1'
      summit_api_key = ENV['SUMMIT_API_KEY']
      summit_api_secret = ENV['SUMMIT_API_SECRET']
      myString = summit_api_key+':'+summit_api_secret

      auth = Base64.strict_encode64(myString)
      body = ActiveSupport::JSON.encode({
        message: mySchedule.message,
        contactName: mySchedule.contact_name,
        senderName: user.name
        })
      payload = ActiveSupport::JSON.encode({
        destinations: format_phone(mySchedule.contact.phone),
        internal_caller_id_number: ENV['FROM_NUMBER'],
        internal_caller_id_name: 'TimeFor',
        destination_type: 'outbound',
        application: 'time_for',
        schedule: get_scheduled_call_time(mySchedule),
        application_data: body,
        external_caller_id_number: ENV['FROM_NUMBER']
        })

      url = URI(summit_url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["authorization"] = 'Basic ' + auth
      request["content-type"] = 'application/json'
      request["cache-control"] = 'no-cache'
      request.body = payload

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        myResponseBody = response.read_body
        create_scheduled_call(mySchedule, myResponseBody)
      else
        nil
      end
    end

    def schedule_user(schedule)
      User.find(schedule.user_id)
    end

    def format_phone(phone)
      number = Phonelib.parse(phone)
      number.e164
    end

    def create_scheduled_call(schedule, responseBody)
      mySchedule = schedule
      myResponseBody = responseBody

      json_response = ActiveSupport::JSON.decode(myResponseBody)

      scheduled_call_id = json_response["data"][0]["scheduled_call_id"]

    end

    def get_offset(timezone)
      offset = ActiveSupport::TimeZone.new(timezone).formatted_offset
    end

    def get_scheduled_call_time(schedule)
      timezone = schedule.frequency.timezone
      myStartDate = schedule.frequency.start_date.strftime("%F")
      myStartTime = schedule.frequency.time.strftime("%H:%M")
      myOffset = get_offset(timezone)

      build_timestamp = myStartDate + " " + myStartTime + " " + myOffset

      scheduled_call_timestamp = build_timestamp.to_time.utc.strftime("%F %T")
    end
end
