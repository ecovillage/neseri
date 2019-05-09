class Admin::SeminarsController < NeseriController
  before_action :authenticate_user!

  def index
    future_seminars = Seminar.user_versions.future.order(created_at: :desc)
    @pagy_current, @current_seminars = pagy(future_seminars,
      page_param: :current_page, items: 10)

    past_seminars = Seminar.user_versions.past.order(created_at: :desc)
    @pagy_past, @past_seminars = pagy(past_seminars,
      page_param: :past_page, items: 10)

    authorize!
  end

  def show
    @seminar = Seminar.find(params[:id])
    authorize! @seminar
  end

end
