require "application_system_test_case"

class SeminarShowAdminFeaturesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test "admin sees copy icons and 2-decimal cost formatting; a plain user does not see copy icons" do
    sign_in users(:admin)
    visit seminar_path(seminars(:one))

    assert_selector '.copy-icon', minimum: 1
    assert_text '375,00'
    assert_text '225,00'
    sign_out users(:admin)

    sign_in users(:jane)
    visit seminar_path(seminars(:bob_and_janes_seminar))

    assert_no_selector '.copy-icon'
  end

  test "the 'view admin copy' link goes to the admin copy, not the user seminar itself" do
    sign_in users(:admin)
    visit seminar_path(seminars(:bob_and_janes_seminar))

    find('a.button', text: 'Admin-Kopie ansehen').click

    assert_current_path edit_admin_admin_seminar_path(seminars(:admin_copy_bob_and_janes_seminar))
  end
end
