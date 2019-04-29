require 'test_helper'

class InstructorUserLinkTest < ActiveSupport::TestCase
  test 'is_correctly_linked? answers correctly' do
    bob_instructor  = seminar_instructors(:bob_and_jane_bob)
    jane_instructor = seminar_instructors(:bob_and_jane_jane)

    # email missing
    refute InstructorUserLink.is_correctly_linked?(bob_instructor)
    # email present
    assert InstructorUserLink.is_correctly_linked?(jane_instructor)
  end


  test 'straightens the instructor email if nil and if user is set' do
    bob_and_janes_seminar = seminars(:bob_and_janes_seminar)
    bob_instructor = seminar_instructors(:bob_and_jane_bob)

    assert_equal bob_and_janes_seminar.seminar_instructors.count, 3

    assert_equal bob_instructor.user, users(:bob)

    last_updated_at = bob_and_janes_seminar.updated_at
    refute bob_instructor.email
    assert users(:bob).email
    InstructorUserLink.create_and_invite! bob_instructor
    assert_equal users(:bob).email, bob_instructor.email
    assert last_updated_at == bob_and_janes_seminar.updated_at
  end

  test "fixes the user if it differs from mail" do
    bob_and_janes_seminar = seminars(:bob_and_janes_seminar)
    unlinked_bob_instructor  = seminar_instructors(:unlinked_bob)

    last_updated_at = bob_and_janes_seminar.updated_at
    assert unlinked_bob_instructor.email
    refute unlinked_bob_instructor.user
    InstructorUserLink.create_and_invite! unlinked_bob_instructor
    assert_equal users(:bob), unlinked_bob_instructor.user
    assert last_updated_at == bob_and_janes_seminar.updated_at
  end

  test "creates, invites and sets the user if not present" do
    bob_and_janes_seminar = seminars(:bob_and_janes_seminar)

    assert_equal bob_and_janes_seminar.seminar_instructors.count, 3

    future_instructor = bob_and_janes_seminar.seminar_instructors.build(email: 'futureinvitee@neseri.tu')

    refute User.find_by(email: 'futureinvitee@neseri.tu')
    InstructorUserLink.create_and_invite! future_instructor
    assert User.find_by(email: 'futureinvitee@neseri.tu')
    assert bob_and_janes_seminar.seminar_instructors.count, 4
    assert_equal bob_and_janes_seminar.seminar_instructors.last.email, bob_and_janes_seminar.seminar_instructors.last.user.email
  end
end

