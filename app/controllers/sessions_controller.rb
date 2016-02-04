class SessionsController < Devise::SessionsController
  def new
    @body_class = "am-splash-screen"
    super
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

end