class Seminars::AttachmentsController < NeseriController
  before_action :authenticate_user!

  def destroy
    @attachment = ActiveStorage::Attachment.find(params[:id])
    authorize! @attachment, to: :destroy?, with: AttachmentPolicy
    @attachment.purge
    helpers.add_flash info: 'attachment.deleted'
    redirect_back fallback_location: @attachment.record
  end
end
