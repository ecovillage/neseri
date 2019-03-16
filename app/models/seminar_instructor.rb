# == Schema Information
#
# Table name: seminar_instructors
#
#  id            :integer          not null, primary key
#  seminar_id    :integer
#  instructor_id :integer
#  qualification :text
#  main_contact  :boolean
#  accommodation :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SeminarInstructor < ApplicationRecord
  belongs_to :seminar
  belongs_to :instructor

  validates :email, uniqueness: true

  before_validation :downcase_strip_email

  def downcase_strip_email
    self.email = email.downcase.strip
  end
end
