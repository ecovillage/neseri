class Seminars::CloneController < NeseriController
  before_action :authenticate_user!

  def create
    @old_seminar = Seminar.find(params[:seminar_id])
    authorize! @old_seminar, with: SeminarPolicy

    if @old_seminar.is_admin_seminar?
      flash[:error] = t(:can_not_copy_admin_seminar)
      redirect_to @old_seminar
    else
      operation = SeminarCloner.call(@old_seminar, current_user: current_user)
      @seminar  = operation.to_record

      flash[:notice] = t(:copy_created)

      render 'seminars/new'
    end
  end
end
