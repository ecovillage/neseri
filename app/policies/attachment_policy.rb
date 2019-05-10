class AttachmentPolicy < ApplicationPolicy
  def destroy?
    !seminar.locked && (user.admin? || Seminar.with_user(user).exists?(seminar.id))
  end

  private

  def attachment
    record
  end

  def seminar
    attachment.record
  end
end
