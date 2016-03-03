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



  def first_occurence
    if self.repeat
      Montrose.every(:week).on(self.repeat_days).at(self.format_time).starts(self.start_date).take(1)[0]
    else
      day = self.start_date.strftime("%A").downcase.to_sym
      Montrose.every(:week).on(day).at(self.format_time).starts(self.start_date).take(1)[0]
    end
  end

end
