# == Schema Information
#
# Table name: instructors
#
#  id         :integer          not null, primary key
#  firstname  :string
#  lastname   :string
#  address    :string
#  email      :string
#  fax        :string
#  phone      :string
#  mobile     :string
#  homepage   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Instructor < ApplicationRecord
  has_one :user

  before_validation :downcase_strip_email
  before_validation :prepend_https_to_homepage

  def downcase_strip_email
    self.email = email.downcase.strip
  end

  def prepend_https_to_homepage
    if self.homepage
      self.homepage = homepage.strip
      if !self.homepage.start_with? "http"
        self.homepage = "https://#{self.homepage}"
      end
    end
  end
end
