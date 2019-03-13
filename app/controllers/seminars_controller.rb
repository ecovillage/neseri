class SeminarsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.admin?
      @seminars = Seminar.all
    else
      @seminars = current_user.seminars
    end
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
      redirect_to @seminar, notice: :seminar_saved
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
      redirect_to @seminar, notice: :seminar_creation_success
    else
      render :new
    end
  end

  private

  def seminar_params
    params.require(:seminar).permit(:title, :subtitle, :description,
      :start_date, :end_date,
      :cancellation_time, :cancellation_reason,
      :attendees_minimum, :attendees_maximum, :attendees_preconditions, :please_bring, 
      :room_extras, :room_material
    )
  end
end
