class SubscriptionPlan < ActiveRecord::Base
  include Payola::Plan

  def redirect_path(subscription)
    '/admin/billing'
  end
end
