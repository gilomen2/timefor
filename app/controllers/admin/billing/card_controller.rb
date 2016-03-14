class Admin::Billing::CardController < ApplicationController
  before_filter :authenticate_user!
  def new
    @user = current_user
    @subscription = Payola::Subscription.find(params[:subscription_id])
    @guid = @subscription.guid
  end
end
