class NeserituController < ApplicationController
  verify_authorized if !Rails.env.production?

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_back fallback_location: root_path,
      flash: {alert: :not_authorized }#, status: :forbidden
  end
end
