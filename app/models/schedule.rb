class Schedule < ActiveRecord::Base
  belongs_to :contact
  before_destroy :cancel_future_scheduled_calls
  has_one :user
  has_many :occurences
  has_one :frequency, dependent: :destroy
  validates_associated :occurences, :frequency

  delegate :name, :to => :contact, :prefix => true

  delegate :start_date, :repeat, :time, :timezone, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency

  def repeat_days
    all_days = self.frequency.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << (k + 's').capitalize
      end
    end
    if true_days.count == 7
      "Everyday at " + self.frequency.time.strftime("%l:%M %p")
    else
      true_days.to_sentence + ' at ' + self.frequency.time.strftime("%l:%M %p")
    end
  end

  def format_time
    self.frequency.time.strftime("%H:%M")
  end

  def scheduled_calls
    ScheduledCall.where("schedule_id = ?", self.id)
  end

  def get_last_occurence_date
    last_occurence = self.occurences.sort_by(&:time).last
    last_occurence.time.to_date
  end

  private

  def cancel_future_scheduled_calls
    now = DateTime.now.utc
    future_scheduled_calls = self.scheduled_calls.where("call_timestamp >= ?", now)
    future_scheduled_calls.each do |call|
      call.cancel_scheduled_call
      call.cancelled = true
      call.save!
    end
  end

end
