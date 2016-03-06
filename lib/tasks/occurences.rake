namespace :occurences do
  desc "Finds occurences without scheduled calls and creates scheduled calls"
  task schedule_calls: :environment do
    occurences_without_scheduled_calls = Occurence.includes(:scheduled_calls).where( :scheduled_calls => { :occurence_id => nil } )

    occurences_without_scheduled_calls.each do |occurence|
      occurence.create_scheduled_call
    end
  end

  desc "Creates next occurence if none exists"
  task next_occurence: :environment do
    tomorrow = DateTime.now.to_date + 1
    repeating_schedules = Schedule.joins(:frequency).where(frequencies: { repeat: true })
    schedules_with_last_occurence_tomorrow = repeating_schedules.where("last_occurence_date <= ?", tomorrow)

    schedules_without_occurences = Schedule.where(last_occurence_date: nil)

    schedules_needing_occurences = schedules_with_last_occurence_tomorrow + schedules_without_occurences

    create_next_occurence(schedules_needing_occurences)
  end

  desc "Creates next occurence of all repeating schedules"
  task all_next_occurences: :environment do
    repeating_schedules = Schedule.joins(:frequency).where(frequencies: { repeat: true })

    create_next_occurence(repeating_schedules)
  end


  desc "Deletes past occurences"
  task delete_past_occurences_and_scheduled_calls: :environment do
    now = DateTime.now
    occurences_in_the_past = Occurence.where("time < ?", now)
    occurences_in_the_past.each do |occ|
      occ.scheduled_calls.delete_all
    end
    occurences_in_the_past.delete_all
  end


  desc "Deletes orphaned occurences"
  task delete_orphaned_occurences: :environment do
    orphaned_occurences = Occurence.where(["schedule_id NOT IN (?)", Schedule.select("id")]).delete_all
  end
end


def create_next_occurence(schedules)
  schedules.each do |schedule|

    def build_next_occurence(schedule)
      frequency = schedule.frequency
      next_occ = frequency.next_occurence
      schedule.last_occurence_date = next_occ.to_date
      schedule.save!
      next_occ
    end

    occ = Occurence.new(time: build_next_occurence(schedule), schedule: schedule)
    if occ.save!
      scheduled_call = occ.create_scheduled_call
    else
      Rails.logger.error = "Error creating occurence and scheduled_call for schedule with id " + schedule.id
    end
  end
end


