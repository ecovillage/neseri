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
    user_seminar = Seminar.new(title: 'Users Version', creator: users(:jane), start_date: DateTime.now, end_date: DateTime.now + 1, cost_participant: 100)
    assert user_seminar.is_user_seminar?

    user_seminar.save!

    admin_seminar = user_seminar.create_admin_seminar
    assert user_seminar.is_user_seminar?
    assert !admin_seminar.is_user_seminar?
    assert admin_seminar.is_admin_seminar?

    assert user_seminar.admin_seminar == admin_seminar
    assert admin_seminar.user_seminar == user_seminar
  end

  test "requires cost_participant" do
    seminar = Seminar.new(title: 'No cost', creator: users(:jane), start_date: DateTime.now, end_date: DateTime.now + 1)

    refute seminar.valid?
    assert_includes seminar.errors.details[:cost_participant].map { |e| e[:error] }, :blank
  end

  test "cost_participant_reduced must not exceed 75% of cost_participant" do
    too_high = Seminar.new(title: 'Reduced too high', creator: users(:jane), start_date: DateTime.now, end_date: DateTime.now + 1,
      cost_participant: 100, cost_participant_reduced: 76)
    refute too_high.valid?
    assert_includes too_high.errors.details[:cost_participant_reduced].map { |e| e[:error] },
      :must_not_exceed_75_percent_of_cost_participant

    at_the_limit = Seminar.new(title: 'Reduced at the limit', creator: users(:jane), start_date: DateTime.now, end_date: DateTime.now + 1,
      cost_participant: 100, cost_participant_reduced: 75)
    assert at_the_limit.valid?
  end

  # Regression test for the (previously mismatched) end_date error key: it
  # used to be :must_be_before_start_date even though both the validation
  # and its message are about end_date having to be *after* start_date.
  test "end_date must be after start_date" do
    seminar = Seminar.new(title: 'Backwards dates', creator: users(:jane), cost_participant: 100,
      start_date: DateTime.new(2020, 1, 2), end_date: DateTime.new(2020, 1, 1))

    refute seminar.valid?
    assert_includes seminar.errors.details[:end_date].map { |e| e[:error] }, :must_be_after_start_date
  end

  test "attendees_maximum must not be smaller than attendees_minimum" do
    seminar = Seminar.new(title: 'Too few max attendees', creator: users(:jane), cost_participant: 100,
      start_date: DateTime.now, end_date: DateTime.now + 1, attendees_minimum: 5, attendees_maximum: 2)

    refute seminar.valid?
    assert_includes seminar.errors.details[:attendees_maximum].map { |e| e[:error] }, :must_be_greater_than_minimum
  end

  test "attached files over 10MB are purged and rejected" do
    seminar = Seminar.new(title: 'Big file', creator: users(:jane), cost_participant: 100,
      start_date: DateTime.now, end_date: DateTime.now + 1)
    seminar.files.attach(io: StringIO.new("a" * 10_000_001), filename: 'big.txt', content_type: 'text/plain')

    refute seminar.valid?
    assert_includes seminar.errors.details[:base].map { |e| e[:error] }, :file_too_big
  end

  test ".admin_copies and .user_versions only return the matching kind" do
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    user_version = seminars(:bob_and_janes_seminar)

    assert_includes Seminar.admin_copies, admin_copy
    refute_includes Seminar.admin_copies, user_version

    assert_includes Seminar.user_versions, user_version
    refute_includes Seminar.user_versions, admin_copy
  end
end
