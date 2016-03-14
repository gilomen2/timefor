class UserMailer < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default :from => 'noreply@timefor.io'

  def trial_expiring(user)
    @user = user
    @days_remaining = pluralize(@user.days_remaining_in_trial, 'Day')
    @subject = 'Your TimeFor Trial is Expiring in ' + @days_remaining
    mail(
      to: @user.email,
      subject: @subject
    )
  end

  def trial_expired(user)
    @user = user
    @subject = 'Your TimeFor Trial is Expired'
    mail(
      to: @user.email,
      subject: @subject
    )
  end

  def payment_failed(user, email, total, last4, brand, attempted, next_payment_attempt)
    @user = user
    @email = email
    @total = total
    @last4 = last4
    @brand = brand
    @attempted = attempted
    @next_payment_attempt = next_payment_attempt
    @subject = 'Action Required: TimeFor Payment Failed'
    mail(
      to: @email,
      subject: @subject
    )
  end

  def subscription_canceled(user)
    @user = user
    @subject = 'Your TimeFor Subscription was Canceled'
    mail(
      to: @user.email,
      subject: @subject
    )
  end

  def final_expired_notice(user)
    @user = user
    @subject = 'Final Notice: Your TimeFor Trial is Expired'
    mail(
      to: @user.email,
      subject: @subject
    )
  end

end
