class SubscriptionNotifier < ActionMailer::Base
  default :from => 'noreply@timefor.io'

  def trial_expiring(user)
    @user = user
    @days_remaining = @user.days_remaining_in_trial
    if @days_remaining <= 3
      mail(
        to: @user.email,
        subject: 'Your TimeFor Trial is Expiring in ' + pluralize(@days_remaining, 'Day')
      )
    end
  end

  def trial_expired(user)
    @user = user
      mail(
        to: @user.email,
        subject: 'Your TimeFor Trial is Expired'
      )
  end


end
