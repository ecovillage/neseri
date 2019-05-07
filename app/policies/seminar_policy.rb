class SeminarPolicy < ApplicationPolicy

  alias_rule :index?, :create?, :new?, to: :access?
  alias_rule :destroy?, :update?, to: :edit?

  def access?
    !user.nil?
  end

  def show?
    !user.nil? && 
      (user.admin? ||
        (seminar.is_user_seminar? &&
          (user_created_seminar? ||
           user_instructs_seminar?)))
  end

  def edit?
    !user.nil? &&
      (unlocked_user_seminar? && (user_created_seminar? || user_instructs_seminar?)) ||
       admin_and_admin_copy?
  end

  private

  def seminar
    record
  end

  def user_created_seminar?
    seminar.creator == user
  end

  def user_instructs_seminar?
    seminar.instructors.exists?(user.id)
  end

  def unlocked_user_seminar?
    !seminar.locked? && seminar.is_user_seminar?
  end

  def admin_and_admin_copy?
    seminar.is_admin_seminar? && user.admin?
  end
end
