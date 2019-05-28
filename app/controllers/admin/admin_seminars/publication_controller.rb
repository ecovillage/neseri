class Admin::AdminSeminars::PublicationController < NeseriController
  before_action :authenticate_user!

  def show
    authorize! :create?,  with: AdminPolicy

    @seminar = Seminar.find(params[:admin_seminar_id])
  end

  def new
    authorize! :create?,  with: AdminPolicy
    authorize! :publish?, with: AdminSeminarPolicy
    
    @seminar = Seminar.find(params[:admin_seminar_id])

    if !@seminar.is_admin_seminar?
      helpers.add_flash warning: t('not_an_admin_seminar')
      redirect_to admin_admin_seminars_path and return
    end

    if @seminar.uuid
      helpers.add_flash warning: t('already published')
      redirect_to admin_admin_seminars_path and return
    end

    @legacy_data_instructor_map = {}
    @user_map                   = {}
    @can_publish = false

    begin
      settings = Settings.load
      @seminar.seminar_instructors.each do |instructor|
        @legacy_data_instructor_map[instructor] = ::Legacy::Instructors.get_for instructor, settings.legacy_db_uri
        @user_map[instructor] = ::Publication::UserMapping.find_by(user: instructor.user)
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      logger.error e.inspect
      helpers.add_flash error: t('publication.connection_refused')
    end

    if all_instructors_legacy_mapped?
      export = ::Legacy::Export.new @seminar
      @can_publish = true
    end

    render "new"
  end

  def create
    authorize! :create?, with: AdminPolicy

    @seminar = Seminar.find(params[:admin_seminar_id])

    if !@seminar.is_admin_seminar?
      helpers.add_flash warning: t('not_an_admin_seminar')
      redirect_to admin_admin_seminars_path and return
    end

    if @seminar.uuid
      helpers.add_flash warning: t('already published')
      redirect_to admin_admin_seminars_path and return
    end

    if !all_instructors_legacy_mapped?
      helpers.add_flash notice: t('missing_referee_mapping')
      redirect_to new_admin_admin_seminar_publication_path
    else
      export = Legacy::Export.new @seminar
      result = export.push Settings.load.legacy_db_uri

      if result == [:failure]
        helpers.add_flash failure: t('publication.failed')
      else
        helpers.add_flash success: t('publication.success_with_link_html', link_url: helpers.legacy_web_url(@seminar))
        @seminar.update!(uuid: export.seminar_uuid)
      end

      redirect_to admin_admin_seminars_path
    end
  end

  private

  def all_instructors_legacy_mapped?
    all_done = User.joins(:seminar_instructors).
      where(seminar_instructors: {seminar_id:  @seminar.id}).
      where.not(id: ::Publication::UserMapping.pluck(:user_id)).count == 0
  end
end
