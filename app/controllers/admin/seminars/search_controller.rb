class Admin::Seminars::SearchController < NeseriController
  before_action :authenticate_user!

  def search
    search = SeminarSearch.new(params[:q])
    seminars = search.apply(Seminar).order(created_at: :desc)
    @pagy, @seminars = pagy(seminars,
      page_param: :current_page, items: 20)

    authorize! :index?, with: AdminPolicy
  end
end
