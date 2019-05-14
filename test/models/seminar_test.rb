# == Schema Information
#
# Table name: seminars
#
#  id                          :integer          not null, primary key
#  title                       :string
#  subtitle                    :string
#  description                 :text
#  attendees_minimum           :integer
#  attendees_maximum           :integer
#  attendees_preconditions     :string
#  please_bring                :string
#  start_date                  :datetime
#  end_date                    :datetime
#  cancellation_time           :integer          default(7)
#  cancellation_reason         :string
#  room_material               :string
#  room_extras                 :string
#  royalty_participant         :decimal(, )
#  royalty_participant_reduced :decimal(, )
#  material_cost               :decimal(, )
#  kind                        :string           default("user")
#  uuid                        :string
#  locked                      :boolean          default(FALSE)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  creator_id                  :integer
#  seminar_kind_id             :integer
#  accommodation               :string
#  user_seminar_id             :integer
#  alternative_dates           :text
#  other_extras                :text
#  room_wish_id                :integer
#  active                      :boolean          default(TRUE)
#  room_comment                :text
#

require 'test_helper'

class SeminarTest < ActiveSupport::TestCase
  test "can be an admin_seminar (which is related to a user_seminar)" do
    user_seminar = Seminar.new(title: 'Users Version', creator: users(:jane), start_date: DateTime.now, end_date: DateTime.now + 1)
    assert user_seminar.is_user_seminar?

    user_seminar.save!

    admin_seminar = user_seminar.create_admin_seminar
    assert user_seminar.is_user_seminar?
    assert !admin_seminar.is_user_seminar?
    assert admin_seminar.is_admin_seminar?

    assert user_seminar.admin_seminar == admin_seminar
    assert admin_seminar.user_seminar == user_seminar
  end
end
