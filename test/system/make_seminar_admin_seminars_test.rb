require "application_system_test_case"

class MakeSeminarAdminSeminarsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test "make a copy of a seminar" do
    sign_in users(:admin)
    visit seminar_path(seminars(:one))
    assert_selector "h1", text: "Seminar : MySeminar"

    num_seminars = Seminar.count

    click_on "Create Admin Copy"
    assert seminars(:one).is_user_seminar?
    assert seminars(:one).admin_seminar.is_admin_seminar?

    assert_equal num_seminars + 1, Seminar.count
  end
end
