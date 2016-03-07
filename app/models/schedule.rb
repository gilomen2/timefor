class Schedule < ActiveRecord::Base
  belongs_to :contact
  before_destroy :cancel_future_scheduled_calls
  has_one :user
  has_many :occurences, dependent: :nullify
  has_one :frequency, dependent: :destroy
  validates_presence_of :message, :contact
  accepts_nested_attributes_for :frequency
  validates_associated :frequency, :occurences
  before_save :set_last_occurence_date

  delegate :name, :to => :contact, :prefix => true

  delegate :start_datetime, :repeat, :timezone, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency

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

  def display_date_time
    self.frequency.display_start_datetime
  end

  def display_start_date
    self.frequency.display_start_date
  end

  def scheduled_calls
    ScheduledCall.where("schedule_id = ?", self.id)
  end

  def get_last_occurence_date
    last_occurence = self.occurences.sort_by(&:time).last
    last_occurence.time
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

    def set_last_occurence_date
      frequency = self.frequency
      self.last_occurence_datetime = frequency.first_occurence.in_time_zone(frequency.timezone)
    end
end
