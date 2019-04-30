class Admin::LocksController < NeseriController
  before_action :authenticate_user!

  def create
    authorize! :create?, with: LockPolicy
    if seminar.update(locked: true)
      helpers.add_flash success: t(:seminar_locked)
      redirect_back fallback_location: seminars_path
    else
      helpers.add_flash failure: t(:seminar_locked_failed)
      redirect_back fallback_location: seminars_path
    end
  end

  def destroy
    authorize! :destroy?, with: LockPolicy
    if seminar.update(locked: false)
      helpers.add_flash success: t(:seminar_unlocked)
      redirect_back fallback_location: seminars_path
    else
      helpers.add_flash failure: t(:seminar_unlock_failed)
      redirect_back fallback_location: seminars_path
    end
  end

  private

  def seminar
    Seminar.find(params[:seminar_id])
  end
end
