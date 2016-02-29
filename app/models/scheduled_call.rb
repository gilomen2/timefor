class ScheduledCall < ActiveRecord::Base
  belongs_to :occurence
  validates_presence_of :call_id
end
