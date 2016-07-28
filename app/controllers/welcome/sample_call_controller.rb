class Welcome::SampleCallsController < ApplicationController
  def new
		@sample_call = SampleCall.new
  end

  def create
    @sample_call = SampleCall.new(sample_call_params)
    respond_to do |format|
      if @sample_call.save
        format.json { render action: 'making_sample_call', status: :created, location: [:welcome, @sample_call] }
        format.js   { render action: 'making_sample_call', status: :created, location: [:welcome, @sample_call] }
      else
        format.json { render action: 'error' }
        format.js   { render action: 'error' }
      end
    end
  end

  private

  def sample_call_params
    params.require(:sample_call).permit(:name, :phone)
  end

  def make_sample_call(name, phone)
    summit_url = 'https://api.us1.corvisa.io/call/schedule'
    summit_api_key = ENV['SUMMIT_API_KEY']
    summit_api_secret = ENV['SUMMIT_API_SECRET']
    myString = summit_api_key+':'+summit_api_secret

    auth = Base64.strict_encode64(myString)
    body = ActiveSupport::JSON.encode({
      message: "To create scheduled calls to your contacts with your own message, sign up for your trial account now.",
      contactName: name,
      senderName: TimeFor
      })
    payload = ActiveSupport::JSON.encode({
      destinations: format_phone(mySchedule.contact.phone),
      internal_caller_id_number: ENV['FROM_NUMBER'],
      internal_caller_id_name: 'TimeFor',
      destination_type: 'outbound',
      application: 'time_for',
      application_data: body,
      log_dst: format_phone(number),
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
end
