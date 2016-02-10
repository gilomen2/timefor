class SchedulePolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? && record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      schedules = []
      if user
        all_schedules = scope.all
        all_schedules.each do |schedule|
          if user.id == schedule.user_id
            schedules << schedule
          end
        end
      end
      schedules
    end
  end

end
