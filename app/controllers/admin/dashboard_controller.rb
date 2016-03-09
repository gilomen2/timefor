class Admin::DashboardController < ApplicationController
	def index
    	authorize :dashboard, :show?
    	@user = current_user
	end

end
