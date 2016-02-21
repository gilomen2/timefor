class CreateFrequencies < ActiveRecord::Migration
  def change
    create_table :frequencies do |t|
      t.date :start_date
      t.time :time
      t.boolean :repeat
      t.boolean :sunday
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.references :schedule, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
