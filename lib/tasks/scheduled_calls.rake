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
    (ScheduledCall.orphaned_scheduled_calls.cancelled_scheduled_calls).delete_all
  end
end
