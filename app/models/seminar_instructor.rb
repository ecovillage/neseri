# == Schema Information
#
# Table name: seminar_instructors
#
#  id            :integer          not null, primary key
#  seminar_id    :integer
#  user_id       :integer
#  qualification :text
#  main_contact  :boolean
#  accommodation :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  email         :string
#  comment       :string
#  contactable   :boolean          default(FALSE)
#

class SeminarInstructor < ApplicationRecord
  belongs_to :seminar, inverse_of: :seminar_instructors, optional: true
  belongs_to :user, inverse_of: :seminar_instructors, optional: true

  validates :seminar, presence: true

  # Custom validator (app/validators/email_validator.rb): checks syntax
  # *and* that the domain has a real, IANA-registered TLD (also accepts
  # internationalized domains), which plain format regexps don't catch.
  validates :email, presence: true, email: true
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address, presence: true
  validates :phone, presence: true


  before_validation :downcase_strip_email

  after_validation :set_user, on: [ :create, :update ]

  def downcase_strip_email
    self.email = self.email.downcase.strip if self.email.present?
  end

  def set_user
    self.user = User.find_by(email: self.email)
  end
end
