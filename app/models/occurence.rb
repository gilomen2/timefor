class Occurence < ActiveRecord::Base
  belongs_to :schedule
  has_many :scheduled_calls, dependent: :destroy


  def make_summit_request
    myOccurence = self
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
end
