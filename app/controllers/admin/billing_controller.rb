class Admin::BillingController < ApplicationController
  def index
    @user = current_user
    @subscription = lookup_subscription
    respond_to do |format|
        format.html { }
        format.json { render action: 'index' }
        format.js   { render action: 'index' }
    end
    @card_expired = check_expiration(@subscription)
    @active_subscription = determine_active(@subscription)
  end

  def check_expiration(subscription)
    subscription.card_expiration < Time.now
  end

  def lookup_subscription
    if Payola::Subscription.where(owner: @user).where(stripe_status: "active").exists?
      Payola::Subscription.where(owner: @user).where(stripe_status: "active").first
    end
  end

  def determine_active(subscription)
    subscription.present? && (subscription.stripe_status = "active")
  end

end
