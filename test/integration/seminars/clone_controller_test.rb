require 'test_helper'

class Seminars::CloneControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "a signed-in user can clone any accessible (non-admin) seminar into a prefilled new-seminar form" do
    seminar = seminars(:bob_and_janes_seminar)
    sign_in users(:veteran)

    # SeminarCloner only builds the clone in memory; it's the regular
    # seminars#create action (via the rendered "new" form) that persists it.
    assert_no_difference 'Seminar.count' do
      post seminar_clone_path(seminar_id: seminar.id)
    end

    assert_response :success
    assert_select '.notification', text: 'Kopie erstellt'
    assert_select "input[value='#{seminar.title}']"
  end

  test "an admin copy can not be cloned" do
    seminar = seminars(:admin_copy_bob_and_janes_seminar)
    sign_in users(:admin)

    assert_no_difference 'Seminar.count' do
      post seminar_clone_path(seminar_id: seminar.id)
    end

    assert_redirected_to seminar
  end
end
