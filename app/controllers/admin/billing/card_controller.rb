class Admin::Billing::CardController < ApplicationController
  def new
    @user = current_user
    @subscription = Payola::Subscription.find(params[:subscription_id])
    @guid = @subscription.guid
  end

end
