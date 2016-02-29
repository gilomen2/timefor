class Occurence < ActiveRecord::Base
  belongs_to :schedule
  before_destroy :cancel_scheduled_calls
  has_many :scheduled_calls, dependent: :destroy

  private

  def cancel_scheduled_calls
      scheduled_calls = self.scheduled_calls
      scheduled_calls.each do |call|
        call_id = call.call_id
        if make_cancellation_request(call_id) == false
          self.errors[:base] << "There was a problem cancelling scheduled calls. Please try again later."
          puts self.errors.first
          return false
        end
      end
    end

    def make_cancellation_request(call_id)
      summit_url = 'https://api.us1.corvisa.io/call/schedule/' + call_id + '/cancel'
      summit_api_key = ENV['SUMMIT_API_KEY']
      summit_api_secret = ENV['SUMMIT_API_SECRET']
      myString = summit_api_key+':'+summit_api_secret

      auth = Base64.strict_encode64(myString)

      url = URI(summit_url)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["authorization"] = 'Basic ' + auth
      request["content-type"] = 'application/json'
      request["cache-control"] = 'no-cache'

      response = http.request(request)

      myResponseBody = response.read_body

      case response
      when Net::HTTPSuccess
        puts myResponseBody
      else
        begin
          json_response = ActiveSupport::JSON.decode(myResponseBody)
          if json_response["errorMessage"] = "Cannot cancel a call once it has started"
            puts json_response
          else
            self.errors[:base] << "There was a problem cancelling scheduled calls. Please try again later."
            puts self.errors
            puts json_response
            return false
          end
        rescue JSON::ParserError => e
          return false
        end
      end
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

      return json_response["data"][0]["created_timestamp"], json_response["data"][0]["scheduled_call_id"]

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
