class Admin::BillingController < ApplicationController
  before_filter :store_location
  before_filter :authenticate_user!
  def index
    @user = current_user
    @subscription = lookup_subscription(@user)
    @owner = payola_can_modify_subscription?(@user, @subscription)
    respond_to do |format|
        format.html { }
        format.json { render action: 'index' }
        format.js   { render action: 'index' }
    end
    @card_expired = check_expiration(@user, @subscription)
    @active_subscription = determine_active(@user)
    @default = @subscription && @user.account_status.match(/\bdefault\b/) ? true : false
  end

  def check_expiration(user, subscription)
    if determine_active(user)
      subscription.card_expiration < Time.now
    end
  end

  def lookup_subscription(user)
    if Payola::Subscription.where(owner: user).where(stripe_status: "active").exists?
      Payola::Subscription.where(owner: user).where(stripe_status: "active").last
    end
  end

  def determine_active(user)
    user.payola_subscriptions.where(stripe_status: "active").present? && (user.account_status == "subscriber")
  end

  def cancel_subscription
    @user = current_user
    subscription = Payola::Subscription.find_by!(owner_id: current_user.id, state: 'active')
    @user.account_status = "canceled"
    @user.save!
    if Payola::CancelSubscription.call(subscription)
      redirect_to admin_billing_index_path
      flash[:success] = "Subscription canceled."
    else
      redirect_to admin_billing_index_path
      flash[:warning] = "There was a problem canceling the subscription. Please try again."
    end
  end

  def payola_can_modify_subscription?(user, subscription)
    if determine_active(user)
      subscription.owner == current_user
    else
      false
    end
  end

  def login
    store_locationfor(:user, admin_billing_index_path)
  end

  private

    def store_location
      store_location_for(:user, admin_billing_index_path)
    end
end
