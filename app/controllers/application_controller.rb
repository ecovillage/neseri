class ApplicationController < ActionController::Base
  before_action :configure_permitted_devise_parameters, if: :devise_controller?
  impersonates :user

  def configure_permitted_devise_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :tos_agreement])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:tos_agreement])
  end

  def after_sign_in_path_for(resource)
    seminars_path(current_user)
  end
end
