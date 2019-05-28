class Admin::AdminSeminars::Publication::UserMappingsController < NeseriController
  before_action :authenticate_user!

  def create
    authorize! :create?, with: AdminPolicy

    user = User.find(params[:user_id])
    user_mapping = ::Publication::UserMapping.find_or_create_by(user: user)
    user_mapping.update!(uuid: params[:uuid])

    redirect_back fallback_location: admin_admin_seminars_path
  end
end

