class ContactPolicy < ApplicationPolicy
  def create?
    user.present?
    user.account_status == "trial" || user.account_status == "subscriber"
  end

  def new?
    create?
  end

  def update?
    create?
    user.present? && record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def clone?
    create?
  end
  
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
