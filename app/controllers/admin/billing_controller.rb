class Admin::BillingController < ApplicationController
  def index
    @user = current_user
    @subscription = Payola::Subscription.where(owner: @user).where(stripe_status: "active")
  end
end
