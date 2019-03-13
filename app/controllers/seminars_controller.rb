class SeminarsController < ApplicationController
  before_action :authenticate_user!

  def index
    @seminars = Seminar.all
  end

  def show
    @seminar = Seminar.find(params[:id])
  end

  def new
    @seminar = Seminar.new
  end

  def create
    @seminar = Seminar.new(seminar_params)
    if @seminar.save
      redirect_to @seminar, notice: :seminar_creation_success
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
