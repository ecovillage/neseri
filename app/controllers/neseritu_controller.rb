class NeserituController < ApplicationController
  include Pagy::Backend

  verify_authorized if !Rails.env.production?
  before_action :authenticate_user!
  before_action :force_tos_accept!

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_back fallback_location: root_path,
      flash: {alert: :not_authorized }
  end

  def force_tos_accept!
    if !current_user.admin && !current_user.tos_accepted_at
      redirect_to tos_path, alert: t(':need_to_accept_to_use_service')
    end
  end
end
