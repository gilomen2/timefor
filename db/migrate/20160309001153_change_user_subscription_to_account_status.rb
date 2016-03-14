class ChangeUserSubscriptionToAccountStatus < ActiveRecord::Migration
  def up
    rename_column :users, :subscription, :account_status
  end
end
