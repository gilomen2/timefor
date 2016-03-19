class Users::SessionsController < Devise::SessionsController
  def new
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || admin_dashboard_index_path
    super
  end

end
