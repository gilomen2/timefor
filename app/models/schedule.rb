class Schedule < ActiveRecord::Base
  belongs_to :contact
  before_destroy :cancel_future_scheduled_calls
  has_one :user
  has_many :occurences
  has_one :frequency, dependent: :destroy
  validates_associated :occurences, :frequency

  delegate :name, :to => :contact, :prefix => true

  delegate :start_date, :repeat, :time, :timezone, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency

  def repeat_days
    all_days = self.frequency.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << (k + 's').capitalize
      end
    end
    if true_days.count == 7
      "Everyday at " + self.frequency.time.strftime("%l:%M %p")
    else
      true_days.to_sentence + ' at ' + self.frequency.time.strftime("%l:%M %p")
    end
  end

  def format_time
    self.frequency.time.strftime("%H:%M")
  end

  def scheduled_calls
    ScheduledCall.where("schedule_id = ?", self.id)
  end

  private

  def cancel_future_scheduled_calls
    now = DateTime.now.utc
    future_scheduled_calls = self.scheduled_calls.where("call_timestamp >= ?", now)
    future_scheduled_calls.each do |call|
      cancel_scheduled_call(call)
      call.cancelled = true
      call.save!
    end
  end


  def cancel_scheduled_call(scheduled_call)
    call_id = scheduled_call.call_id
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


end
