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

  def show
    @body_class = "am-splash-screen"
    @includes_form = true
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      resource.set_expiration_date
      flash[:notice] = "Account confirmed."
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
    super
  end

end
