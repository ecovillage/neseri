class Admin::RoomsController < NeseriController
  before_action :authenticate_user!

  def index
    @rooms = Room.all.order(active: :desc, name: :asc)
    authorize! Room.new
  end

  def new
    @room = Room.new
    authorize!
  end

  def create
    @room = Room.new(room_params)
    @room.kind = 'event'
    authorize!
    if @room.save
      helpers.add_flash success: t('rooms.create.success')
      redirect_to admin_rooms_path
    else
      render :new
    end
  end

  def destroy
    @room = Room.find(params[:id])
    authorize!
    @room.update!(active: false)
    helpers.add_flash success: t('rooms.deactivated')
    redirect_to admin_rooms_path
  end

  # reactivate
  def update
    @room = Room.find(params[:id])
    authorize!
    @room.toggle!(:active)
    redirect_to admin_rooms_path
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end
