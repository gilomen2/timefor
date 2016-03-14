class AddNextBillingDateAndDefaultToUser < ActiveRecord::Migration
  def change
    add_column :users, :next_billing_date, :date
    add_column :users, :default, :boolean
  end
end
