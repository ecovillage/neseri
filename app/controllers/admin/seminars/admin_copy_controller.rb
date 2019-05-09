class Admin::Seminars::AdminCopyController < NeseriController
  before_action :authenticate_user!

  def create
    @user_seminar = Seminar.find(params[:seminar_id])
    authorize! @user_seminar, with: AdminSeminarPolicy

    if @user_seminar.admin_seminar
      helpers.add_flash t("admin.seminar.admin_copy.has_already")
      @admin_seminar = @user_seminar.admin_seminar
    elsif @user_seminar.is_admin_seminar?
      helpers.add_flash t("admin.seminar.admin_copy.is_already")
      @admin_seminar = @user_seminar
    else
      operation = AdminSeminarCloner.call(@user_seminar)
      @admin_seminar = operation.to_record
      @admin_seminar.save!
      helpers.add_flash notice: t("admin.seminar.admin_copy.created")
    end

    redirect_to edit_admin_admin_seminar_path(@admin_seminar)
  end
end
