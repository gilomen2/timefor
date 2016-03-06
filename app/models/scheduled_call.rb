class ScheduledCall < ActiveRecord::Base
  belongs_to :occurence
  validates_presence_of :call_id

  scope :orphaned_uncancelled_calls, -> {where(["schedule_id NOT IN (?)", Schedule.select("id")]).where(cancelled: false)}

  scope :cancelled_scheduled_calls, -> {where(cancelled: true)}

  scope :orphaned_scheduled_calls, -> {where(["schedule_id NOT IN (?)", Schedule.select("id")])}

  def make_summit_request
    myOccurence = self.occurence
    mySchedule = Schedule.find(myOccurence.schedule_id)
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
    else
      nil
      Rails.logger.error "ERROR error in summit request for schedule id " + mySchedule.id + " and occurence id " + occurence.id
    end
  end


  def cancel_scheduled_call
    call_id = self.call_id
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
      self.cancelled = true
      self.save!
      Rails.logger.info "SUCCESS cancelled call with call_id " + call_id
      puts myResponseBody
    else
      begin
        json_response = ActiveSupport::JSON.decode(myResponseBody)
        if json_response["errorMessage"] = "Cannot cancel a call once it has started"
          puts json_response
          Rails.logger.info "SUCCESS Call with call id " + call_id + " is in the past"
        else
          self.errors[:base] << "There was a problem cancelling scheduled calls. Please try again later."
          puts self.errors
          puts json_response
          Rails.logger.error "ERROR Call with call id " + call_id + " could not be cancelled"
          return false
        end
      rescue JSON::ParserError => e
        return false
      end
    end
  end

  private

    def schedule_user(schedule)
      User.find(schedule.user_id)
    end

    def get_scheduled_call_time(occurence)
      scheduled_call_timestamp = occurence.time.strftime("%F %T")
    end


    def format_phone(phone)
      number = Phonelib.parse(phone)
      number.e164
    end

end
