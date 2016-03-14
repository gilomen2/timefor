class AddTrialPeriodToSubscriptionPlan < ActiveRecord::Migration
  def change
    add_column :subscription_plans, :trial_period_days, :integer
  end
end
