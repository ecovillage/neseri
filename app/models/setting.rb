# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  key        :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Setting < ApplicationRecord
  validates :key, uniqueness: { case_sensitive: false }
end
