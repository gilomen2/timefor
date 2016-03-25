namespace :scheduled_calls do
  desc "Cancels uncancelled orphaned scheduled_calls"
  task cancel_uncancelled_orphaned_calls: :environment do

    ScheduledCall.orphaned_uncancelled_calls.each do |call|
      call.cancel_scheduled_call
      call.cancelled = true
      call.save!
    end
  end

  desc "Deletes cancelled scheduled_calls"
  task delete_cancelled_scheduled_calls: :environment do
    ScheduledCall.cancelled_scheduled_calls.delete_all
  end

  desc "Deletes orphaned scheduled_calls"
  task delete_orphaned_scheduled_calls: :environment do
    orphaned = ScheduledCall.orphaned_scheduled_calls.cancelled_scheduled_calls + ScheduledCall.nil_schedule_scheduled_calls + ScheduledCall.nil_occurence_scheduled_calls
    orphaned.map(&:delete)
  end

  desc "CAUTION: Cancel all future scheduled_calls for Summit domain"
  task cancel_all_scheduled_calls_for_summit_domain: :environment do
    require 'uri'
    require 'net/http'
    require 'json'

    def cancel_scheduled_call(call)
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
        puts myResponseBody
      else
          json_response = JSON.parse(myResponseBody)
          if json_response["errorMessage"] = "Cannot cancel a call once it has started"
            puts json_response
          else
            puts json_response
          end
      end
    end


    url = URI("https://api.us1.corvisa.io/scheduled_call?canceled_timestamp=None&schedule__gte=-0minutes")

    summit_api_key = ENV['SUMMIT_API_KEY']
    summit_api_secret = ENV['SUMMIT_API_SECRET']
    myString = summit_api_key+':'+summit_api_secret

    auth = Base64.strict_encode64(myString)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["authorization"] = 'Basic ' + auth
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'

    response = http.request(request)
    all_response = response.read_body
    json_all_response = JSON.parse(all_response)
    json_all_response["data"].each do |call|
      cancel_scheduled_call(call["scheduled_call_id"])
    end
  end
end
