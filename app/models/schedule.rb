class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_one :user
  before_destroy :cancel_scheduled_calls
  has_many :scheduled_calls, dependent: :destroy
  has_one :frequency, dependent: :destroy
  validates_associated :scheduled_calls, :frequency


  delegate :name, :to => :contact, :prefix => true

  delegate :start_date, :repeat, :timezone, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency

  def repeat_days
    all_days = self.frequency.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << k.capitalize
      end
    end
    true_days.to_sentence + ' at ' + self.frequency.time.strftime("%l:%M %p")
  end

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

end
