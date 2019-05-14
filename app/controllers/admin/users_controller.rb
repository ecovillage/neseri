class Admin::UsersController < NeseriController
  before_action :authenticate_user!

  def index
    search = UserSearch.new(params[:q])
    admin_users = search.apply(User.all.where(admin: true).order(created_at: :desc))
    @pagy_admin, @admin_users = pagy(admin_users,
                                     page_param: :admin_users_page)

    users = search.apply(User.all.where(admin: false).order(created_at: :desc))
    @pagy, @users = pagy(users,
                         page_param: :users_page)
    authorize!
  end

  def show
    @user     = User.find(params[:id])
    @seminars = Seminar.with_user(@user)
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

