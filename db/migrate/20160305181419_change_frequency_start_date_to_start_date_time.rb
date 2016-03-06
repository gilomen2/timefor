class ChangeFrequencyStartDateToStartDateTime < ActiveRecord::Migration
  def up
    change_column :frequencies, :start_date, :datetime
    rename_column :frequencies, :start_date, :start_datetime
  end

  def down
    change_column :frequencies, :start_date, :date
  end
end
