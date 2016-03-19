class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_many :occurences, dependent: :nullify
  has_one :frequency, dependent: :destroy

  validates_presence_of :message, :contact

  before_destroy :cancel_future_scheduled_calls
  accepts_nested_attributes_for :frequency

  delegate :name, :to => :contact, :prefix => true
  delegate :user_id, :to => :contact
  delegate :start_datetime, :start_date, :time, :repeat, :timezone, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :to => :frequency, :prefix => true

  scope :repeating_schedules, -> {joins(:frequency).where('frequencies.repeat = ?', true)}
  scope :schedules_with_last_occurence_tomorrow, -> {joins(:frequency).where("last_occurence_datetime <= ?", (Time.now.utc + 1.day))}
  scope :schedules_without_occurences, -> {where(last_occurence_datetime: nil)}


  def repeat_days
    all_days = self.frequency.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << (k + 's').capitalize
      end
    end
    if true_days.count == 7
      "Everyday"
    else
      true_days.to_sentence
    end
  end

  def display_time
    self.frequency.display_start_time
  end

  def owner_is_active
    user = User.find(self.user_id)
    if user.account_status == "trial" || user.account_status == "subscriber"
      true
    else
      false
    end
  end

  def user
    self.contact.user
  end

  def get_last_occurence_date
    last_occurence = self.occurences.last
    last_occurence.time
  end

  def display_date_time
    self.frequency.display_start_datetime
  end

  def display_start_date
    self.frequency.display_start_date
  end

  def scheduled_calls
    ScheduledCall.where("schedule_id = ?", self.id)
  end

  def cancel_future_scheduled_calls
    now = DateTime.now.utc
    future_scheduled_calls = self.scheduled_calls.where("call_timestamp >= ?", now)
    future_scheduled_calls.each do |call|
      call.cancel_scheduled_call
      call.cancelled = true
      call.save!
    end
    self.last_occurence_datetime = nil
    self.save!
  end

  def create_occurence_and_scheduled_call
    def build_next_occurence
      frequency = self.frequency
      if self.last_occurence_datetime.nil?
        next_occ = frequency.first_occurence
      else
        next_occ = frequency.next_occurence
      end
      next_occ.utc
    end

    occ = Occurence.new(time: build_next_occurence, schedule: self)
    if occ.save!
      scheduled_call = occ.create_scheduled_call
    else
      Rails.logger.error = "Error creating occurence and scheduled_call for schedule with id " + self.id
    end
  end

end
