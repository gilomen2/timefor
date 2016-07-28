class SampleCall < ActiveRecord::Base
  validates_presence_of :name, :phone
  validates :phone, phone: true
end
