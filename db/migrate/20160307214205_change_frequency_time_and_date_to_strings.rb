class ChangeFrequencyTimeAndDateToStrings < ActiveRecord::Migration
  def up
    change_column :frequencies, :time, :text
    change_column :frequencies, :start_date, :text
  end

  def down
    change_column :frequencies, :time, :time
    change_column :frequencies, :start_date, :date
  end
end
