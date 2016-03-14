class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  def create
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  def edit
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  def update
    @body_class = "am-splash-screen"
    @includes_form = true
    super
  end

  protected
    def after_sign_up_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_update_path_for(resource)
      flash[:notice] = "User information updated"
      edit_user_registration_path
    end

    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
end
