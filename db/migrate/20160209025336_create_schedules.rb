class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :message
      t.datetime :next_call_time
      t.datetime :last_successful_summit_request
      t.references :contact, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
