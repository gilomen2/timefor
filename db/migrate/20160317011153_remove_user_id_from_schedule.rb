class RemoveUserIdFromSchedule < ActiveRecord::Migration
  def change
    remove_column :schedules, :user_id
  end
end
