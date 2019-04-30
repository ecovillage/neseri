class Admin::UsersController < NeseriController
  before_action :authenticate_user!

  def index
    @pagy, @users = pagy(User.all.order(created_at: :desc))
    authorize!
  end
end

