module DeviseHelper
  def devise_error_messages!
    return false if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| msg }
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    messages
  end

  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

end
