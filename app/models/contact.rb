class Contact < ActiveRecord::Base
  validates_presence_of :name, :phone
	belongs_to :user

end
