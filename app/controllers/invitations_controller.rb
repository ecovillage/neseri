class InvitationsController < Devise::InvitationsController

  before_action :update_sanitized_params, only: :update

  # PUT /resource/invitation
  def update
    invitation_token = Devise.token_generator.digest(
      resource_class, :invitation_token,
      update_resource_params[:invitation_token])

    self.resource = resource_class.where(invitation_token: invitation_token).first

    # Manually check that checkbox was checked
    if update_resource_params[:tos_agreement] != "1"
      resource.invitation_token = update_resource_params[:invitation_token]
      resource.errors.add(:tos_agreement, :accepted)
      respond_with_navigational(resource) { render :edit }
    else
      resource.update(tos_accepted_at: DateTime.now)
      super
    end
  end


  protected

  def update_sanitized_params
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:email, :password, :password_confirmation, :invitation_token, :tos_agreement])
  end
end
