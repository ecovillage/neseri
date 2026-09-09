class Admin::AdminSeminarsController < NeseriController
  before_action :authenticate_user!
  #authorize with: AdminSeminarPolicy

  def index
    @pagy, @seminars = pagy(Seminar.admin_copies.order(created_at: :desc), items: 20)
    authorize! @seminars, with: AdminSeminarPolicy
  end

  def show
    @seminar = Seminar.find(params[:id])

    if @seminar.is_user_seminar? && !@seminar.admin_seminar
      helpers.add_flash notice: t('no admin copy yet')
      authorize! @seminar
      redirect_to @seminar
      return
    elsif @seminar.is_user_seminar? && @seminar.admin_seminar
      @seminar = @seminar.admin_seminar
    end

    authorize! @seminar

    if @seminar.uuid
      redirect_to admin_admin_seminar_publication_path(@seminar)
    else
      redirect_to edit_admin_admin_seminar_path(@seminar)
    end
  end

  def edit
    @seminar = Seminar.find(params[:id])
    # Authorizing before the is_user_seminar? check (matching #update)
    # keeps `verify_authorized` satisfied on every path, including the
    # early return right below.
    authorize! @seminar

    if @seminar.is_user_seminar?
      # TODO could be nice and redirect or find the admin copy ...
      helpers.add_flash notice: t('not_an_admin_copy')
      # Without this `and return`, execution fell through to the
      # redirect below and double-rendered (500) whenever this was reached
      # for a user seminar's id (nothing in the UI links here with one,
      # but the route doesn't stop it).
      redirect_to admin_admin_seminars_path and return
    end

    if @seminar.uuid
      redirect_to admin_admin_seminar_path(@seminar) and return
    end
  end

  def update
    @seminar = Seminar.find(params[:id])
    authorize! @seminar

    if @seminar.is_user_seminar?
      helpers.add_flash notice: t('not_an_admin_copy')
      # Without this `and return`, execution fell through to
      # @seminar.update below and double-rendered (500) whenever this was
      # reached for a user seminar's id (e.g. its own creator, who's
      # authorized above the same way as for the actual seminars#update).
      redirect_to admin_admin_seminars_path and return
    end

    if @seminar.update(seminar_params)
      # deal with referees (new invitations, ... )
      helpers.add_flash notice: I18n.t('seminar.saved')
      redirect_to admin_admin_seminar_path(@seminar)
    else
      render :edit
    end
  end

  private

  def seminar_params
    # TODO these should be taken from and/or shared with seminar_controller
    params.require(:seminar).permit(:title, :subtitle, :description,
      :start_date, :end_date,
      :alternative_dates,
      :accommodation,
      :cancellation_time, :cancellation_reason,
      :attendees_minimum, :attendees_maximum, :attendees_preconditions, :please_bring, 
      :room_material, :room_comment,
      :seminar_kind_id,
      :royalty_participant, :royalty_participant_reduced, :material_cost, :honorar, :locked,
      seminar_instructors_attributes: [:id, :email, :main_contact, :contactable, :comment, :accommodation, :qualification, :_destroy]
    )
  end
end
