class ChangeSchedulesLastOccurenceDateToDatetime < ActiveRecord::Migration
  def up
    change_column :schedules, :last_occurence_date, :datetime
    rename_column :schedules, :last_occurence_date, :last_occurence_datetime
  end

  def down
    change_column :schedules, :last_occurence_date, :date
  end
end
