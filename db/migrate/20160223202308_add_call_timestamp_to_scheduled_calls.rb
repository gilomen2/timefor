class AddCallTimestampToScheduledCalls < ActiveRecord::Migration
  def change
  	add_column :scheduled_calls, :call_timestamp, :datetime
  end
end
