class Occurence < ActiveRecord::Base
  belongs_to :schedule
  has_many :scheduled_calls, dependent: :destroy


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
      Rails.logger.info "ERROR scheduled_call with call_id " + json_response["data"][0]["scheduled_call_id"] + " failed to save."
    end
  end

end
