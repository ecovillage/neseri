class SeminarPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    true
  end

  def create?
    true
  end

  def show?
    user.admin? || seminar.creator == user
  end

  def update?
    user.admin? || seminar.creator == user
  end

  def edit?
    user.admin? || seminar.creator == user
  end

  private

  def seminar
    record
  end
end
