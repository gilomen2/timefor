namespace :users do
	desc "Expire trial accounts older than 7 days"
	task expire_trials: :environment do
		User.trial_accounts.each do |user|
			if user.days_remaining_in_trial <= 0
				user.account_status = "expired"
				user.save!
				user.schedules.each do |schedule|
					schedule.cancel_future_scheduled_calls
				end
			end
		end
	end
end