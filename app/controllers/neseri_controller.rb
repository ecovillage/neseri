class NeseriController < ApplicationController
  include Pagy::Backend

  verify_authorized if !Rails.env.production?
  before_action :authenticate_user!
  before_action :force_tos_accept!
  before_action :show_profile_warning

  rescue_from ActionPolicy::Unauthorized do |exception|
    helpers.add_flash alert: t(:unauthorized)
    redirect_back fallback_location: root_path
  end

  def show_profile_warning
    if current_user&.teaching_seminars&.present? && current_user.profile_missing?
      notice_text = t(:please_fill_out_profile_html, profile_path: edit_instructor_path)
      # Prevent double entries (could be done in helper method, too)
      if ![*flash[:notice]].include? notice_text
        helpers.add_flash notice: notice_text
      end
    end
  end

  def force_tos_accept!
    if current_user && !current_user.admin && !current_user.tos_accepted_at
      helpers.add_flash alert: t(:need_to_accept_to_use_service)
      redirect_to tos_path
    end
  end
end
