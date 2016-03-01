class Frequency < ActiveRecord::Base
  belongs_to :schedule

  def repeat_days
    all_days = self.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << k.to_sym
      end
    end
    true_days
  end


  def format_time
    timezone = self.timezone
    myStartTime = self.time.strftime("%H:%M")
    myOffset = ActiveSupport::TimeZone.new(self.timezone).formatted_offset

    build_timestamp = myStartTime + " " + myOffset

    time = build_timestamp.to_time.strftime("%T %z")
  end

end
