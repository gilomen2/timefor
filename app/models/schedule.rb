class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_one :user
  has_many :occurences, dependent: :destroy
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
        true_days << k.capitalize
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

end
