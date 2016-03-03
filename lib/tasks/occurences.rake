namespace :occurences do
  desc "Finds occurences without scheduled calls and creates scheduled calls"
  task schedule_calls: :environment do
    occurences_without_scheduled_calls = Occurence.includes(:scheduled_calls).where( :scheduled_calls => { :occurence_id => nil } )

    occurences_without_scheduled_calls.each do |occurence|
      make_summit_request(occurence)
    end
  end


  desc "Creates next 3 occurences of schedule"
  task next_3_occurences: :environment do
    tomorrow = DateTime.now.to_date + 1
    schedules_with_last_occurence_tomorrow = Schedule.where(last_occurence_date: tomorrow)
    schedules_without_occurences = Schedule.where(last_occurence_date: nil)

    schedules_needing_occurences = schedules_with_last_occurence_tomorrow + schedules_without_occurences

    create_next_3_occurences(schedules_needing_occurences)
  end

  desc "Deletes past occurences"
  task delete_past_occurences: :environment do
    now = DateTime.now
    occurences_in_the_past = Occurence.where("time < ?", now)
    occurences_in_the_past.each do |occ|
      occ.scheduled_calls.delete_all
    end
    occurences_in_the_past.delete_all
  end


  desc "Deletes cancelled scheduled_calls"
  task delete_cancelled_scheduled_calls: :environment do
    ScheduledCall.where(cancelled: true).delete_all
  end
end






def make_summit_request(occurence)
  myOccurence = occurence
  mySchedule = myOccurence.schedule
  user = schedule_user(mySchedule)
  summit_url = 'https://api.us1.corvisa.io/call/schedule'
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
    schedule: get_scheduled_call_time(myOccurence),
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
    create_scheduled_call(myOccurence, myResponseBody)
  else
    nil
    Rails.logger.info "ERROR error in summit request for schedule id " + mySchedule.id + " and occurence id " + occurence.id
  end
end


def create_scheduled_call(occurence, responseBody)
  myOccurence = occurence
  mySchedule = occurence.schedule
  myResponseBody = responseBody

  json_response = ActiveSupport::JSON.decode(myResponseBody)

  scheduled_call = ScheduledCall.new(schedule_id: mySchedule.id, occurence: myOccurence, call_timestamp: json_response["data"][0]["schedule"], call_id: json_response["data"][0]["scheduled_call_id"] )
  if scheduled_call.save!
    Rails.logger.info "SUCCESS created scheduled_call with call id " + json_response["data"][0]["scheduled_call_id"]
  else
    Rails.logger.info "ERROR scheduled_call with call_id " + json_response["data"][0]["scheduled_call_id"] + " failed to save."
  end
end


def schedule_user(schedule)
  User.find(schedule.user_id)
end

def get_scheduled_call_time(occurence)
  scheduled_call_timestamp = occurence.time.to_time.utc.strftime("%F %T")
end


def format_phone(phone)
  number = Phonelib.parse(phone)
  number.e164
end



def create_next_3_occurences(schedules)
  schedules.each do |schedule|
    frequency = schedule.frequency
    unless schedule.last_occurence_date.nil?
      day_after_last_occurence = schedule.last_occurence_date + 1
    else
      day_after_last_occurence = DateTime.now.to_date
    end

    occurence_array = Montrose.every(:week).on(frequency.repeat_days).at(frequency.format_time).starts(day_after_last_occurence).take(3)
    a = []
    occurence_array.each do |occurence|
      a << Occurence.new(time: occurence.utc, schedule: schedule)
    end

    if a.each(&:save!)
      schedule.last_occurence_date = get_last_occurence_date(a)
      schedule.save!
    end
  end
end


def get_last_occurence_date(occurences)
  last_occurence = occurences.sort_by(&:time).last
  last_occurence.time.to_date
end
