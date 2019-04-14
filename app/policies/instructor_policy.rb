class InstructorPolicy < ApplicationPolicy
  def show?
    (record.user == user) || user.admin?
  end

  def edit?
    (record.user == user) || user.admin?
  end

  def update?
    (record.user == user) || user.admin?
  end

  def create?
    (record.user == user) || user.admin?
  end
end
