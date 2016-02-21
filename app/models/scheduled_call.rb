class ScheduledCall < ActiveRecord::Base
  belongs_to :schedule
  validates_presence_of :call_id
end
