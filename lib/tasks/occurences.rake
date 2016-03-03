namespace :occurences do
  desc "Finds occurences without scheduled calls and creates scheduled calls"
  task schedule_calls: :environment do
    occurences_without_scheduled_calls = Occurence.includes(:scheduled_calls).where( :scheduled_calls => { :occurence_id => nil } )

    occurences_without_scheduled_calls.each do |occurence|
      occurence.make_summit_request
    end
  end


  desc "Creates next 3 occurences of schedule"
  task next_3_occurences: :environment do
    tomorrow = DateTime.now.to_date + 1
    schedules_with_last_occurence_tomorrow = Schedule.where("last_occurence_date <= ?", tomorrow)
    schedules_without_occurences = Schedule.where(last_occurence_date: nil)

    schedules_needing_occurences = schedules_with_last_occurence_tomorrow + schedules_without_occurences

    create_next_3_occurences(schedules_needing_occurences)
  end

  desc "Deletes past occurences"
  task delete_past_occurences: :environment do
    now = DateTime.now
    occurences_in_the_past = Occurence.where("time < ?", now)
    occurences_in_the_past.each do |occ|
      occ.scheduled_calls.delete_all
    end
    occurences_in_the_past.delete_all
  end


  desc "Deletes cancelled scheduled_calls"
  task delete_cancelled_scheduled_calls: :environment do
    ScheduledCall.where(cancelled: true).delete_all
  end
end






def create_next_3_occurences(schedules)
  schedules.each do |schedule|
    frequency = schedule.frequency
    unless schedule.last_occurence_date.nil?
      day_after_last_occurence = schedule.last_occurence_date + 1
    else
      day_after_last_occurence = DateTime.now.to_date
    end

    occurence_array = Montrose.every(:week).on(frequency.repeat_days).at(frequency.format_time).starts(day_after_last_occurence).take(3)
    a = []
    occurence_array.each do |occurence|
      a << Occurence.new(time: occurence.utc, schedule: schedule)
    end

    if a.each(&:save!)
      schedule.last_occurence_date = get_last_occurence_date(a)
      schedule.save!
    end
  end
end


def get_last_occurence_date(occurences)
  last_occurence = occurences.sort_by(&:time).last
  last_occurence.time.to_date
end
