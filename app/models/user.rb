class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :contacts
  has_many :schedules
  before_create :make_trial

  scope :trial_accounts, -> {where(account_status: "trial")}

  def payola_subscriptions
  	Payola::Subscription.where(owner: self)
  end

  def days_remaining_in_trial
  	unless self.confirmed_at.nil?
	  	account_start_date = self.confirmed_at.to_date
	  	now = Time.now.to_date
	  	trial_length = 7
	  	unless (now - account_start_date).to_i > 7
	  		(trial_length - (now - account_start_date)).to_i
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
    self.schedules.each do |schedule|
    	schedule.cancel_future_calls
    end
  end

  def handle_default(event)

  end

end
