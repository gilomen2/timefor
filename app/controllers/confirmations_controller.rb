class ConfirmationsController < Devise::ConfirmationsController
  def new
    @body_class = "am-splash-screen"
    super
  end

  def create
    @body_class = "am-splash-screen"
    super
  end

end
