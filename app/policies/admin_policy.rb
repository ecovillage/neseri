class AdminPolicy < ApplicationPolicy
  # Bare subclasses (RoomPolicy, SeminarKindPolicy, LockPolicy) rely on these
  # aliases for every rule they gate on - without update?/destroy? here,
  # `authorize!` for their #update/#destroy actions (reactivating/toggling
  # a room or seminar kind, unlocking a seminar) had no rule to find and
  # was unconditionally unauthorized, even for admins.
  alias_rule :index?, :create?, :new?, :update?, :destroy?, to: :manage?

  def manage?
    user && user.admin?
  end
end
