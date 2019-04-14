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
#  email         :string
#  comment       :string
#

class SeminarInstructor < ApplicationRecord
  belongs_to :seminar, inverse_of: :seminar_instructors, optional: true
  belongs_to :user, inverse_of: :seminar_instructors, optional: true

  validates :seminar, presence: true


  before_validation :downcase_strip_email

  def downcase_strip_email
    self.email = email.downcase.strip
  end
end
