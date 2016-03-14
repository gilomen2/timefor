class AddExpiredTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :expired_time, :datetime
  end
end
