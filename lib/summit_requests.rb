module SummitRequests
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
	          Rails.logger.info "SUCCESS Call with call id " + call_id + " is in the past"
	        else
	          self.errors[:base] << "There was a problem cancelling scheduled calls. Please try again later."
	          puts self.errors
	          puts json_response
	          Rails.logger.info "ERROR Call with call id " + call_id + " could not be cancelled"
	          return false
	        end
	      rescue JSON::ParserError => e
	        return false
	      end
	    end
	 end
end