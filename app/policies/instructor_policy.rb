class InstructorPolicy < ApplicationPolicy
  def show?
    (record == user) || user.admin?
  end

  def edit?
    (record == user) || user.admin?
  end

  def update?
    (record == user) || user.admin?
  end

  def create?
    (record == user) || user.admin?
  end
end
