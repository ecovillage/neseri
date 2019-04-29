class AdminPolicy < ApplicationPolicy
  alias_rule :index?, :create?, :new?, to: :manage?

  def manage?
    user && user.admin?
  end
end
