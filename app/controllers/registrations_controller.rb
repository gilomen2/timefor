class RegistrationsController < Devise::RegistrationsController
  def new
    @body_class = "am-splash-screen"
    super
  end

  def create
    @body_class = "am-splash-screen"
    super
  end

  protected

  def after_update_path_for(resource)
  	flash[:notice] = "User information updated"
  	edit_user_registration_path
  end

end