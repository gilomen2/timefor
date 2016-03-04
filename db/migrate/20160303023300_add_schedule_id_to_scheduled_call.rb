class AddScheduleIdToScheduledCall < ActiveRecord::Migration
  def change
    add_column :scheduled_calls, :schedule_id, :integer
  end
end
