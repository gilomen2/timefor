class SessionsController < Devise::SessionsController
  def new
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || admin_dashboard_index_path
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

end
