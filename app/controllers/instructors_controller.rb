class InstructorsController < NeserituController
  before_action :authenticate_user!
  
  def show
    @instructor = current_user
    authorize! @instructor
  end

  def edit
    @instructor = current_user
    authorize! @instructor
  end

  def update
    @instructor = current_user
    @instructor.update instructor_params
    authorize! @instructor
    if @instructor.save
      redirect_to instructor_path, notice: t(:instructor_updated)
    else
      render :edit
    end
  end

  private

  def instructor_params
    params.require(:user).permit(:firstname,
      :lastname,
      :address,
      :fax,
      :phone,
      :mobile,
      :homepage)
  end
end
