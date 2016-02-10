class ScheduledCall < ActiveRecord::Base
  belongs_to :schedule, dependent: :destroy
end
