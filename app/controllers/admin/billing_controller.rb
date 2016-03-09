class Admin::BillingController < ApplicationController
  def index
    @user = current_user
    @subscription = Payola::Subscription.where(owner: @user).where(stripe_status: "active")
    respond_to do |format|
        format.html { }
        format.json { render action: 'index' }
        format.js   { render action: 'index' }
    end
  end
end
