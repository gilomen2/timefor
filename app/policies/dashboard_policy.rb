class DashboardPolicy < Struct.new(:user, :dashboard)
  def show?
    user.present?
  end
end
