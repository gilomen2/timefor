class ConfirmationsController < Devise::ConfirmationsController
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

end
