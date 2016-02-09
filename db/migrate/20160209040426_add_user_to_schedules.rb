class AddUserToSchedules < ActiveRecord::Migration
  def change
    add_reference :schedules, :user, index: true, foreign_key: true
  end
end
