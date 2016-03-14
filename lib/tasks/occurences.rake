namespace :occurences do
  desc "Finds occurences without scheduled calls and creates scheduled calls"
  task schedule_calls: :environment do

    Occurence.occurences_without_scheduled_calls.each do |occurence|
      occurence.create_scheduled_call
    end

  end

  desc "Creates next occurence if none exists"
  task next_occurence: :environment do

    schedules_needing_occurences = Schedule.repeating_schedules.schedules_with_last_occurence_tomorrow + Schedule.schedules_without_occurences

    create_next_occurence(schedules_needing_occurences)

  end

  desc "Creates next occurence of all repeating schedules"
  task all_next_occurences: :environment do
    repeating_schedules = Schedule.repeating_schedules

    create_next_occurence(repeating_schedules)

  end


  desc "Deletes past occurences"
  task delete_past_occurences_and_scheduled_calls: :environment do
    Occurence.occurences_in_the_past.each do |occ|
      occ.scheduled_calls.delete_all
    end
    Occurence.occurences_in_the_past.delete_all
  end


  desc "Deletes orphaned occurences"
  task delete_orphaned_occurences: :environment do
    orphaned = Occurence.orphaned_occurences + Occurence.nil_schedules
    orphaned.map(&:delete)
  end
end


def create_next_occurence(schedules)
  schedules.each do |schedule|
    if schedule.owner_is_active
      schedule.create_occurence_and_scheduled_call
    end
  end
end

