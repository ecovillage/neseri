class Admin::SettingsController < NeseriController
  before_action :authenticate_user!

  def index
    authorize! :index?, with: AdminPolicy
    @settings = Settings.load
  end

  def update
    authorize! :update?, with: AdminPolicy
    helpers.add_flash notice: t(:settings_saved)
    @settings = Settings.new(settings_params)
    @settings.save
    render :index
  end

  private
  
  def settings_params
    params.require(:settings).permit(:legacy_uri)
  end
end
