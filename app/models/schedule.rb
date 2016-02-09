class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_many :scheduled_calls
  has_one :frequency
end
