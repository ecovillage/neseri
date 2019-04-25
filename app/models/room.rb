# == Schema Information
#
# Table name: rooms
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kind       :text
#  active     :boolean
#

class Room < ApplicationRecord
  has_many :seminars

  validates :name, uniqueness: true
end
