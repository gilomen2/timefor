class Contact < ActiveRecord::Base
  validates_presence_of :name, :phone
	belongs_to :user
  has_many :schedules
  # before_save :format_phone

  # def format_phone
  #   phone = Phonelib.parse(self.phone)
  #   self.phone = '1'+phone.sanitized
  # end


end
