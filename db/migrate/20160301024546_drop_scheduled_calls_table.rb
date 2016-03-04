class DropScheduledCallsTable < ActiveRecord::Migration
  def up
    drop_table :scheduled_calls
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
