class Seminar < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :title, presence: true

  validate :end_after_start
  validates :start_date, :end_date, presence: true

  private

  def end_after_start
    return if end_date.blank? || start_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, :must_be_before_start_date)
    end
  end
end
