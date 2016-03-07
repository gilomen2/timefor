class AddStartDateToFrequency < ActiveRecord::Migration
  def change
    add_column :frequencies, :start_date, :date
  end
end
