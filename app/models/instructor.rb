# == Schema Information
#
# Table name: instructors
#
#  id         :integer          not null, primary key
#  firstname  :string
#  lastname   :string
#  address    :string
#  fax        :string
#  phone      :string
#  mobile     :string
#  homepage   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Instructor < ApplicationRecord
  has_one :user

  has_many :seminar_instructors, inverse_of: :instructor
  has_many :seminars, through: :seminar_instructors

  before_validation :prepend_https_to_homepage

  def prepend_https_to_homepage
    if self.homepage
      self.homepage = homepage.strip
      if !self.homepage.start_with? "http"
        self.homepage = "https://#{self.homepage}"
      end
    end
  end
end
