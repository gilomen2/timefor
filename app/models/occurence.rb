class Occurence < ActiveRecord::Base
  belongs_to :schedule
  has_many :scheduled_calls, dependent: :nullify
  validates_presence_of :time, :schedule
  after_save :set_last_occurence_date

  scope :occurences_without_scheduled_calls, -> {includes(:scheduled_calls).where(scheduled_calls: {occurence_id: nil})}

  scope :occurences_in_the_past, -> {where("time < ?", Time.now.utc)}

  scope :orphaned_occurences, -> {where(["schedule_id NOT IN (?)", Schedule.select("id")])}

  scope :nil_schedules, -> {where(schedule_id: nil)}

  def my_frequency
    Frequency.find_by(schedule: self.schedule)
  end

  def create_scheduled_call
    myOccurence = self
    mySchedule = self.schedule
    @scheduled_call = ScheduledCall.new
    @scheduled_call.occurence = myOccurence
    myResponseBody = @scheduled_call.make_summit_request

    json_response = ActiveSupport::JSON.decode(myResponseBody)

    scheduled_call = ScheduledCall.new(schedule_id: mySchedule.id, occurence: myOccurence, call_timestamp: json_response["data"][0]["schedule"], call_id: json_response["data"][0]["scheduled_call_id"] )
    if scheduled_call.save!
      Rails.logger.info "SUCCESS created scheduled_call with call id " + json_response["data"][0]["scheduled_call_id"]
    else
      Rails.logger.error "ERROR scheduled_call with call_id " + json_response["data"][0]["scheduled_call_id"] + " failed to save."
    end
  end


  private

  def set_time
    schedule = self.schedule
    frequency = schedule.frequency
    self.time = frequency.first_occurence
  end

  def set_last_occurence_date
    schedule = self.schedule
    schedule.last_occurence_datetime = self.time.in_time_zone(schedule.frequency.timezone)
    schedule.save!
  end

end
