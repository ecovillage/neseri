class EmailsPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
