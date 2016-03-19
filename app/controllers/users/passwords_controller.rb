class Users::PasswordsController < Devise::PasswordsController
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
    def after_resetting_password_path_for(resource)
      signed_in_root_path(resource)
    end
end
