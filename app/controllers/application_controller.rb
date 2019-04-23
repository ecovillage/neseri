class ApplicationController < ActionController::Base
  before_action :configure_permitted_devise_parameters, if: :devise_controller?

  def configure_permitted_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :tos_agreement])
  end
end
