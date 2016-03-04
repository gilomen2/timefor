namespace :scheduled_calls do
  desc "Cancels uncancelled orphaned scheduled_calls"
  task cancel_uncancelled_orphaned_calls: :environment do
    orphaned_uncancelled_calls = ScheduledCall.where(["schedule_id NOT IN (?)", Schedule.select("id")]).where(cancelled: false)

    orphaned_uncancelled_calls.each do |call|
      call.cancel_scheduled_call
      call.cancelled = true
      call.save!
    end
  end

  desc "Deletes cancelled scheduled_calls"
  task delete_cancelled_scheduled_calls: :environment do
    ScheduledCall.where(cancelled: true).delete_all
  end

  desc "Deletes orphaned scheduled_calls"
  task delete_orphaned_scheduled_calls: :environment do
    orphaned_scheduled_calls = ScheduledCall.where(["schedule_id NOT IN (?)", Schedule.select("id")]).where(cancelled: true).delete_all
  end
end
