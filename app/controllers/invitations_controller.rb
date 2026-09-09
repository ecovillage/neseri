class InvitationsController < Devise::InvitationsController

  before_action :update_sanitized_params, only: :update

  # PUT /resource/invitation
  def update
    # find_by_invitation_token(token, true) is the same lookup GET /edit's
    # resource_from_invitation_token before_action uses, and - just like the
    # plain `resource_class.where(invitation_token: ...).first` this
    # replaces - returns nil for a token that doesn't match any invitation
    # (already accepted on another device/tab, or tampered with). Unlike
    # that before_action, both branches below used to call methods on
    # `resource` unconditionally, which 500'd with NoMethodError instead of
    # showing an error message. Handle the nil case the same way GET /edit
    # already does, before touching `resource` at all.
    self.resource = resource_class.find_by_invitation_token(update_resource_params[:invitation_token], true)

    if resource.nil?
      set_flash_message(:alert, :invitation_token_invalid) if is_flashing_format?
      redirect_to invalid_token_path_for(resource_name) and return
    end

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
