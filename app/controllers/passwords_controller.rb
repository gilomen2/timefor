class PasswordsController < Devise::PasswordsController
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

end
