class UsersController < ApplicationController
  def index
    @body_class = "am-splash-screen"
    @includes_form = true
  end

  def confirmation
    @body_class = "am-splash-screen"
    @includes_form = true
  end
end
