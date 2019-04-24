class Admin::SeminarKindsController < NeserituController
  before_action :authenticate_user!

  def index
    @seminar_kinds = SeminarKind.all.order(active: :desc, name: :asc)
    authorize! SeminarKind.new
  end

  def new
    @seminar_kind = SeminarKind.new
    authorize!
  end

  def create
    @seminar_kind = SeminarKind.new(seminar_kind_params)
    authorize!
    if @seminar_kind.save
      flash[:success] = t('seminar_kinds.create.success')
      redirect_to admin_seminar_kinds_path
    else
      render :new
    end
  end

  def destroy
    @seminar_kind = SeminarKind.find(params[:id])
    authorize!
    @seminar_kind.update!(active: false)
    flash[:success] = t('seminar_kinds.deactivated')
    redirect_to admin_seminar_kinds_path
  end

  # reactivate
  def update
    @seminar_kind = SeminarKind.find(params[:id])
    authorize!
    @seminar_kind.toggle!(:active)
    redirect_to admin_seminar_kinds_path
  end

  private

  def seminar_kind_params
    params.require(:seminar_kind).permit(:name, :description)
  end
end
