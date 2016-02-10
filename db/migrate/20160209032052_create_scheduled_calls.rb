class CreateScheduledCalls < ActiveRecord::Migration
  def change
    create_table :scheduled_calls do |t|
      t.string :call_id
      t.references :schedule, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
