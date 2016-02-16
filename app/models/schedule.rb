class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_one :user
  has_many :scheduled_calls
  has_one :frequency
  before_destroy :cancel_scheduled_calls


  delegate :name, :to => :contact, :prefix => true

  delegate :start_date, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency


  private

    def cancel_scheduled_calls
      scheduled_calls = self.scheduled_calls
      scheduled_calls.each do |call|
        call_id = call.call_id
        make_cancellation_request(call_id)
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

      myResponse = response.read_body

      puts myResponse
    end
end
