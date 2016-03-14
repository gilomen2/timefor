class Admin::DashboardController < ApplicationController
  before_filter :authenticate_user!
	def index
    authorize :dashboard, :show?
    @user = current_user
    @default_days = days_since_default(@user)
	end

  def days_since_default(user)
    if user.default
      TimeDifference.between(user.default_date, Time.now.utc.to_date).in_days
    end
  end

end
