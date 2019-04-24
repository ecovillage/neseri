class SeminarKindPolicy < ApplicationPolicy
  include ActionPolicy::Policy::Aliases
  alias_rule :index?, :create?, :new?, to: :manage?

  def manage?
    user.admin?
  end
end
