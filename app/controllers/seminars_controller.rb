class SeminarsController < NeseriController
  before_action :authenticate_user!

  def index
    if current_user.admin?
      helpers.add_flash(hint:
        t(:admin_seminars_click_here_html,
          admin_seminars_link: admin_admin_seminars_path))
    end

    future_own_seminars = Seminar.with_user(current_user).
      user_versions.future.order(created_at: :desc)
    @pagy_current, @current_seminars = pagy(future_own_seminars,
      page_param: :current_page, items: 10)

    past_own_seminars = Seminar.with_user(current_user).
      user_versions.past.order(created_at: :desc)
    @pagy_past, @past_seminars = pagy(past_own_seminars,
      page_param: :past_page, items: 10)

    authorize!
  end

  def show
    @seminar = Seminar.find(params[:id])
    authorize! @seminar
  end

  def edit
    @seminar = Seminar.find(params[:id])
    authorize! @seminar
  end

  def update
    @seminar = Seminar.find(params[:id])

    authorize! @seminar
    if @seminar.update(seminar_params)
      @seminar.seminar_instructors.find_each do |instructor|
        next if InstructorUserLink.is_correctly_linked?(instructor)
        InstructorUserLink.create_and_invite! instructor
        if !instructor.save
          helpers.add_flash error: t(:could_not_save_instructor)
        end
      end

      redirect_to @seminar, notice: I18n.t('seminar.saved')
    else
      render :edit
    end
  end

  def new
    @seminar = Seminar.new
    authorize!
  end

  def create
    @seminar = Seminar.new(seminar_params)
    @seminar.creator = current_user
    authorize!

    if @seminar.save
      # new referees? invite them!
      @seminar.seminar_instructors.find_each do |instructor|
        next if InstructorUserLink.is_correctly_linked?(instructor)
        InstructorUserLink.create_and_invite! instructor
        if !instructor.save
          helpers.add_flash error: t(:could_not_save_instructor)
        end
      end

      redirect_to @seminar, notice: I18n.t('seminar.saved')
    else
      render :new
    end
  end

  def destroy
    @seminar = Seminar.find(params[:id])
    authorize! @seminar
    @seminar.update!(active: false)
    flash[:success] = t('seminar.pulled_back')
    redirect_to seminars_path
  end

  private

  def seminar_params
    params.require(:seminar).permit(:title, :subtitle, :description,
      :start_date, :end_date,
      :cancellation_time, :cancellation_reason,
      :attendees_minimum, :attendees_maximum, :attendees_preconditions, :please_bring, 
      :room_extras, :room_material,
      :seminar_kind_id,
      :royalty_participant, :royalty_participant_reduced, :material_cost, :honorar,
      seminar_instructors_attributes: [:id, :email, :comment, :accommodation, :qualification, :_destroy]
    )
  end
end
