class Admin::Billing::SubscriptionsController < ApplicationController
  # bring in the `render_payola_status` helper.
  include Payola::StatusBehavior
  skip_before_filter :verify_authenticity_token


  def new
    @plan = SubscriptionPlan.first
    @title = "Start Subscription"
  end

  def create
    # do any required setup here, including finding or creating the owner object
    owner = current_user # this is just an example for Devise

    # set your plan in the params hash
    params[:plan] = SubscriptionPlan.find_by(id: params[:plan_id])

    # call Payola::CreateSubscription

    subscription = Payola::CreateSubscription.call(params, owner)

    # Render the status json that Payola's javascript expects
    render_payola_status(subscription)

    if owner.payola_subscriptions.any?
      owner.account_status = "subscriber"
      owner.save!
    end

  end

  def cancel_subscription
    subscription = Payola::Subscription.find_by!(owner_id: current_user.id, state: 'active')
    Payola::CancelSubscription.call(subscription)
    current_user.account_status = "canceled"
    current_user.save!
  end

  def show
    @subscription = Payola::Subscription.find(params[:id])
    render json: @subscription
  end


end
