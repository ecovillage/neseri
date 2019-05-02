class CloneSeminarsController < NeseriController
  before_action :authenticate_user!

  def update
    @old_seminar = Seminar.find(params[:clone_seminar_id])
    authorize! @old_seminar, with: SeminarPolicy

    operation = SeminarCloner.call(@old_seminar, current_user: current_user)
    @seminar  = operation.to_record

    flash[:notice] = t(:copy_created)

    render 'seminars/new'
  end
end
