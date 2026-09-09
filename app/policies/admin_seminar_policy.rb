class AdminSeminarPolicy < AdminPolicy
  # Used by Admin::AdminSeminars::PublicationController#new to gate
  # publishing an admin seminar to the legacy site - without this alias,
  # `authorize! :publish?, with: AdminSeminarPolicy` had no rule to find
  # and was unconditionally unauthorized, even for admins.
  alias_rule :publish?, to: :manage?

  #scope_for :relation do |relation|
  #  relation.where(creator: user)
  #end
  #relation_scope do |scope|
  #  if user.admin?
  #    scope
  #  else
  #    # join this where email adress of user is in referees mail adresses
  #    scope.where(creator: user)
  #  end
  #end
end
