class InstructorPolicy < ApplicationPolicy
  def show?
    (record.email == user.email) || user.admin?
  end

  def edit?
    (record.email == user.email) || user.admin?
  end

  def update?
    (record.email == user.email) || user.admin?
  end

  def create?
    (record.email == user.email) || user.admin?
  end
end
