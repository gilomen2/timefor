namespace :occurences do
  desc "Finds occurences without scheduled calls and creates scheduled calls"
  task schedule_calls: :environment do
    occurences_without_scheduled_calls = Occurence.includes(:scheduled_calls).where( :scheduled_calls => { :occurence_id => nil } )

    occurences_without_scheduled_calls.each do |occurence|
      make_summit_request(occurence)
    end
  end


  desc "Creates next 30 occurences of schedule"
  task next_30_occurences: :environment do
    tomorrow = DateTime.now.to_date + 1
    schedules_with_last_occurence_tomorrow = Schedule.where(last_occurence_date: tomorrow) 
    schedules_without_occurences = Schedule.where(last_occurence_date: nil)

    schedules_needing_occurences = schedules_with_last_occurence_tomorrow + schedules_without_occurences

    create_next_30_occurences(schedules_needing_occurences)

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
  end
end


def create_scheduled_call(occurence, responseBody)
  myOccurence = occurence
  myResponseBody = responseBody

  json_response = ActiveSupport::JSON.decode(myResponseBody)

  scheduled_call = ScheduledCall.new(occurence: occurence, call_timestamp: json_response["data"][0]["schedule"], call_id: json_response["data"][0]["scheduled_call_id"] )
  scheduled_call.save!
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



def create_next_30_occurences(schedules)
  schedules.each do |schedule|
    frequency = schedule.frequency
    unless schedule.last_occurence_date.nil?
      day_after_last_occurence = schedule.last_occurence_date + 1
    else
      day_after_last_occurence = DateTime.now.to_date
    end
    
    occurence_array = Montrose.every(:week).on(frequency.repeat_days).at(frequency.format_time).starts(day_after_last_occurence).take(30)
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
