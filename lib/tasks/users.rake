namespace :users do
	desc "Expire trial accounts older than 7 days"
	task expire_trials: :environment do
		User.trial_accounts.each do |user|
			if user.days_remaining_in_trial <= 0
				user.account_status = "expired"
				user.expired_time = Time.now.utc
				user.save!
				user.schedules.each do |schedule|
					schedule.cancel_future_scheduled_calls
				end
				UserMailer.trial_expired(user).deliver_now
			end
		end
	end

	desc "Send reminder to accounts still expired after 2 days"
	task remind_expired: :environment do
		expired = User.expired_trials
		expired.each do |user|
			if TimeDifference.between(user.expired_time.to_date, Time.now.utc.to_date).in_days.floor == 2
				UserMailer.final_expired_notice(user).deliver_now
			end
		end
	end


	desc "Send trial expiring email to users whose trials are expiring in 3 days or less."
	task send_expiring_emails: :environment do
		expiring = User.trial_accounts.expiring_3_days + User.trial_accounts.expiring_2_days + User.trial_accounts.expiring_1_day
		expiring.each do |user|
			UserMailer.trial_expiring(user).deliver_now
			user.save!
		end
	end
end
