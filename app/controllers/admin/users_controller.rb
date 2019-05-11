class Admin::UsersController < NeseriController
  before_action :authenticate_user!

  def index
    @pagy, @users = pagy(User.all.order(created_at: :desc))
    authorize!
  end

  def show
    @user = User.find(params[:id])
    authorize! @user
  end

  def impersonate
    user = User.find(params[:id])
    if user == current_user
      helpers.add_flash error: t(:cannot_impersonate_self)
    end
    authorize! with: AdminPolicy
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    authorize! with: AdminPolicy
    redirect_to root_path
  end
end

