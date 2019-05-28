# == Schema Information
#
# Table name: publication_user_mappings
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uuid       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Publication::UserMapping < ApplicationRecord
  self.table_name = "publication_user_mappings"

  belongs_to :user

  validates :user, uniqueness: true
  validates :uuid, presence: true
end
