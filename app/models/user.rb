class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :contacts
  has_many :schedules
  before_create :make_trial

  scope :trial_accounts, -> {where(account_status: "trial")}

  scope :expired_trials, -> {where(account_status: "expired")}

  scope :expiring_3_days, -> {where("expiration_date = ?", (Time.now.utc + 3.days).to_date)}

  scope :expiring_2_days, -> {where("expiration_date = ?", (Time.now.utc + 2.days).to_date)}

  scope :expiring_1_day, -> {where("expiration_date = ?", (Time.now.utc + 1.day).to_date)}

  def payola_subscriptions
  	Payola::Subscription.where(owner: self)
  end

  def set_expiration_date
    self.expiration_date = (self.confirmed_at + 7.days).to_date
    self.save!
  end

  def days_remaining_in_trial
  	unless self.confirmed_at.nil?
      unless self.expiration_date < Time.now.utc.to_date || self.account_status == "subscriber"
        account_start_date = self.confirmed_at.to_date
        expiration_date = self.expiration_date
        TimeDifference.between(account_start_date, expiration_date).in_days.ceil
      else
        0
      end
  	else
  		"Account not yet confirmed"
  	end
  end

  def active
    Payola::Subscription.where(stripe_status: "active")
  end

  def make_trial
  	if self.account_status.nil?
  		self.account_status = "trial"
  	end
  end

  def cancel_subscription(event)
    my_event = Stripe::Event.retrieve(event)
    self.account_status = my_event.data.object.status
    self.save!
    UserMailer.subscription_canceled(self).deliver_now
    self.schedules.each do |schedule|
    	schedule.cancel_future_calls
    end
  end


  def set_default_notified
    unless self.account_status.match(/\bdefault-notified\b/)
      self.account_status = "default-notified-0"
      self.save!
    end
  end

  def update_user_status(event)
    my_event = Stripe::Event.retrieve(event)
    status = my_event.data.object.status
    case status
    when "active"
      self.account_status = "subscriber"
      self.default = false
      self.default_date = nil
    when "past_due"
      self.default = true
      self.default_date = Time.now
    when "canceled"
      self.account_status = "canceled"
    when "unpaid"
      self.account_status = "canceled"
    end
    if my_event.data.object.current_period_end
      next_billing_date = my_event.data.object.current_period_end
      self.next_billing_date = Time.at(next_billing_date)
    end
    self.save!
  end

  def update_next_billing_date(event)
    my_event = Stripe::Event.retrieve(event)
    next_billing_date = my_event.data.object.lines.data[0].period.end
    self.next_billing_date = Time.at(next_billing_date)
    self.save!
  end

  def handle_default(event)
    self.set_default_notified
    unless self.account_status == "default-notified-3"
      self.account_status = self.account_status.succ
      self.save!
      my_event = Stripe::Event.retrieve(event)
      my_charge = Stripe::Charge.retrieve(my_event.data.object.charge)
      my_customer = Stripe::Customer.retrieve(my_charge.customer)
      email = my_customer.email
      total = Money.new(my_charge.amount, "USD").format
      last4 = my_charge.source.last4
      brand = my_charge.source.brand
      case brand
      when "American Express"
        brand = "amex"
      when "Diners Club"
        brand = "diners"
      else
        brand = brand.downcase
      end
      attempted = "Attempted: " + Time.at(my_charge.created).strftime("%m/%d/%y")
      next_payment_attempt = my_event.data.object.next_payment_attempt.nil? ? "Final attempt" : "Next Attempt: " + Time.at(my_event.data.object.next_payment_attempt).strftime("%m/%d/%y")
      UserMailer.payment_failed(self, email, total, last4, brand, attempted, next_payment_attempt).deliver_now
    end
  end

  def handle_expiring
    unless self.days_remaining_in_trial <= 0
      UserMailer.trial_expiring(self).deliver_now
    end
  end

end
