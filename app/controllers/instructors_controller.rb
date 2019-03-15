class InstructorsController < NeserituController
  before_action :authenticate_user!
  
  def show
    @instructor = find_or_build_instructor
    authorize! @instructor
  end

  def create
    @instructor = find_or_build_instructor
    @instructor.update(instructor_params)
    authorize! @instructor
    if @instructor.save
      redirect_to instructor_path, notice: :instructor_updated
    else
      render :edit
    end
  end

  def edit
    @instructor = find_or_build_instructor
    authorize! @instructor
  end

  def update
    @instructor = find_or_build_instructor
    @instructor.update instructor_params
    authorize! @instructor
    if @instructor.save
      redirect_to instructor_path, notice: :instructor_updated
    else
      render :edit
    end
  end

  private

  def find_or_build_instructor
    # or: when an instructor with same email already found
    current_user.instructor || current_user.build_instructor(email: current_user.email)
  end

  def instructor_params
    params.require(:instructor).permit(:firstname,
      :lastname,
      :address,
      :fax,
      :phone,
      :mobile,
      :homepage)
  end
end
