class SessionsController < Devise::SessionsController
  def new
    @body_class = "am-splash-screen"
    @includes_form = true
    if params[:redirect_to].present?
      store_location_for(resource, params[:redirect_to])
    end
    super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || admin_dashboard_index_path
  end

end
