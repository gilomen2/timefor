class RemoveLastSuccessfulSummitRequestFromSchedules < ActiveRecord::Migration
  def change
  	remove_column :schedules, :last_successful_summit_request
  end
end
