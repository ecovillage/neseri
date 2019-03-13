class ApplicationController < ActionController::Base
  verify_authorized
  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_back fallback_location: root_path,
      flash: {alert: :not_authorized }#, status: :forbidden
  end
end
