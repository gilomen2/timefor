class AddCancelledToScheduledCall < ActiveRecord::Migration
  def change
    add_column :scheduled_calls, :cancelled, :boolean
  end
end
