class Frequency < ActiveRecord::Base
  belongs_to :schedule
  extend TimeSplitter::Accessors
  split_accessor :start_datetime

  def repeat_days
    all_days = self.attributes.slice("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
    true_days = []
    all_days.each do |k, v|
      if v
        true_days << k.capitalize
      end
    end
    true_days
  end

  def format_datetime_utc
    myTimezone = self.timezone
    myStartDateTime = self.start_datetime.strftime("%F %T")
    myFormattedDateTime = ActiveSupport::TimeZone[myTimezone].parse(myStartDateTime)
  end

  def start_datetime_in_timezone
    self.start_datetime.in_time_zone(self.timezone)
  end

  def start_date
    self.start_datetime_in_timezone.strftime("%F")
  end

  def start_time
    self.start_datetime_in_timezone.strftime("%T %z")
  end

  def start_day
    self.start_datetime_in_timezone.strftime("%A")
  end


  def next_date_from(ar, date)
    cur_day = date
    cur_day += 1 until ar.include?(cur_day.strftime('%A'))
    cur_day
  end




  def first_occurence
    if self.repeat
      if self.repeat_days.include? self.start_day
        self.start_datetime
      else
        date = self.next_date_from(self.repeat_days, start_datetime_in_timezone)
        date_offset = ActiveSupport::TimeZone[self.timezone].parse(date.to_s).strftime("%z")
        DateTime.new(date.year, date.month, date.day, self.start_datetime_in_timezone.hour, self.start_datetime_in_timezone.min, self.start_datetime_in_timezone.sec, date_offset).utc
      end
    else
      self.start_datetime
    end
  end

  def next_occurence
    date = next_date_from(self.repeat_days, self.schedule.last_occurence_datetime)
    if date = self.schedule.last_occurence_datetime
      day_after_last_occurence = self.schedule.last_occurence_datetime + 1
      date = next_date_from(self.repeat_days, day_after_last_occurence)
    end
    date_offset = ActiveSupport::TimeZone[self.timezone].parse(date.to_s).strftime("%z")
    DateTime.new(date.year, date.month, date.day, self.start_datetime_in_timezone.hour, self.start_datetime_in_timezone.min, self.start_datetime_in_timezone.sec, date_offset)
  end

  def display_start_datetime
    self.start_datetime_in_timezone.strftime("%-m/%-d/%Y %l:%M %P")
  end

  def display_start_date
    self.start_datetime_in_timezone.strftime("%Y-%m-%d")
  end

  def display_start_time
    self.start_datetime_in_timezone.strftime("%H:%M")
  end

end
