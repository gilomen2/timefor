# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


every 1.minute do
  rake "occurences:next_3_occurences", :environment => 'development', :output => 'log/chron.log'
  rake "occurences:schedule_calls", :environment => 'development', :output => 'log/chron.log'
end

every 6.hours do
  rake "occurences:next_3_occurences"
  rake "occurences:schedule_calls"
  rake "delete_past_occurences"
  rake "delete_cancelled_scheduled_calls"
end
