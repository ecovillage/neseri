class SeminarPolicy < ApplicationPolicy
  scope_for :relation do |relation|
    relation.where(creator: user)
  end

  def new?
    true
  end

  alias_rule :index?, :create?, :new?, to: :access?

  def access?
    !user.nil?
  end

  def show?
    user.admin? || seminar.creator == user || seminar.instructors.exists?(user.id)
  end

  def update?
    user.admin? || (seminar.creator == user && !seminar.locked?) || seminar.instructors.exists?(user.id)
  end

  def edit?
    user.admin? || (seminar.creator == user && !seminar.locked?) || seminar.instructors.exists?(user.id)
  end

  private

  def seminar
    record
  end
end
