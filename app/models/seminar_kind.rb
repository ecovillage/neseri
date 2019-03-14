# == Schema Information
#
# Table name: seminar_kinds
#
#  id          :integer          not null, primary key
#  name        :string
#  active      :boolean          default(TRUE)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SeminarKind < ApplicationRecord
  has_many :seminars

  def to_s
    name
  end
end
