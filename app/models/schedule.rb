class Schedule < ActiveRecord::Base
  belongs_to :contact
  has_one :user
  has_many :scheduled_calls
  has_one :frequency


  delegate :name, :to => :contact, :prefix => true

  delegate :start_date, :to => :frequency, :prefix => true

  accepts_nested_attributes_for :frequency

  private


end
