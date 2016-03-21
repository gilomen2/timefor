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
    @includes_form = true
    super
  end

  def update
    @includes_form = true
    super
  end

  protected
    def after_sign_up_path_for(resource)
      signed_in_root_path(resource)
    end

    def after_update_path_for(resource)
      flash[:notice] = "User information updated"
      signed_in_root_path(resource)
    end

    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
end
