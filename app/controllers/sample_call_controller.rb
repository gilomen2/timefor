class SampleCallController < ApplicationController

  def make_sample_call
    # form_data = ActiveSupport::JSON.decode(request)
    form_data_name = params[:name]
    form_data_phone = params[:phone]

    summit_url = 'https://api.us1.corvisa.io/call/schedule'
    summit_api_key = ENV['SUMMIT_API_KEY']
    summit_api_secret = ENV['SUMMIT_API_SECRET']
    myString = summit_api_key+':'+summit_api_secret

    auth = Base64.strict_encode64(myString)
    body = ActiveSupport::JSON.encode({
      message: "To create scheduled calls to your contacts with your own message, sign up for your trial account now at Time Four dot I O.",
      contactName: form_data_name,
      senderName: "TimeFor"
      })
    payload = ActiveSupport::JSON.encode({
      destinations: format_phone(form_data_phone),
      internal_caller_id_number: ENV['FROM_NUMBER'],
      internal_caller_id_name: 'TimeFor',
      destination_type: 'outbound',
      application: 'time_for',
      application_data: body,
      log_dst: format_phone(form_data_phone),
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
      render action: 'sending'
    else
      render action: 'error'
    end
  end

  private

  def format_phone(phone)
    number = Phonelib.parse(phone)
    number.e164
  end
end
