class WelcomeController < ApplicationController
	def index
    @body_class = "homepage"
		@sample_call = SampleCall.new
	end
end
