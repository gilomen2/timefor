class Admin::DashboardController < ApplicationController
	def index
    authorize :dashboard, :show?
	end

  def show

  end
end
