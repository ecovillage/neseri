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
end
