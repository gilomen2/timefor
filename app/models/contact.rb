class Contact < ActiveRecord::Base
  belongs_to :user
  has_many :schedules

  before_destroy :delete_schedules_with_contact
  validates_presence_of :name, :phone
  validates :phone, phone: true

  private

    def delete_schedules_with_contact
      schedules_with_contact = Schedule.where(contact: self)
      schedules_with_contact.destroy_all
    end

end
