class ContactPolicy < ApplicationPolicy

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      contacts = []
      if user
        all_contacts = scope.all
        all_contacts.each do |contact|
          if user == contact.user
            contacts << contact
          end
        end
      end
      contacts
    end
  end

end
