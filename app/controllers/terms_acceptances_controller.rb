class TermsAcceptancesController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:tos]
      current_user.update!(tos_accepted_at: DateTime.now)
    end
    if params[:privacy]
      current_user.update!(privacy_terms_accepted_at: DateTime.now)
    end
    redirect_to root_path
  end
end
