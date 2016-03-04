class AddLastOccurenceDateToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :last_occurence_date, :date
  end
end
