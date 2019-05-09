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
#  main          :boolean          default(FALSE)
#  contactable   :boolean          default(FALSE)
#

class SeminarInstructor < ApplicationRecord
  belongs_to :seminar, inverse_of: :seminar_instructors, optional: true
  belongs_to :user, inverse_of: :seminar_instructors, optional: true

  validates :seminar, presence: true

  # or Devise.email_regexp; https://api.rubyonrails.org/v5.1/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }


  before_validation :downcase_strip_email

  def downcase_strip_email
    self.email = email.downcase.strip
  end
end
