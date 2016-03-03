class Occurence < ActiveRecord::Base
  belongs_to :schedule
  has_many :scheduled_calls, dependent: :destroy
end
