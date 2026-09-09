require 'test_helper'

class Admin::SeminarsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can list all user seminars, split into current and past ones" do
    seminars(:one).update!(start_date: 1.year.from_now, end_date: 1.year.from_now + 1.day)
    seminars(:two).update!(start_date: 1.year.ago, end_date: 1.year.ago + 1.day)

    sign_in users(:admin)
    get admin_seminars_path

    assert_response :success
    assert_match seminars(:one).title, response.body
    assert_match seminars(:two).title, response.body
  end

  test "index is gated by SeminarPolicy#access?, which only requires being signed in - not being an admin" do
    sign_in users(:fulluser)

    get admin_seminars_path
    assert_response :success
  end

  test "show is authorized the same way as the user-facing seminar page, but has no view of its own" do
    sign_in users(:admin)

    # Nothing in the app links to this route (only admin_admin_seminar_path
    # is used) and there's no app/views/admin/seminars/show template, so an
    # authorized request fails on the render, not the authorization.
    get admin_seminar_path(seminars(:one))
    assert_response :not_acceptable
    assert_match 'No view template for interactive request', response.body
  end

  test "show still enforces SeminarPolicy for a seminar the user can't access" do
    sign_in users(:veteran)

    get admin_seminar_path(seminars(:bob_and_janes_seminar))
    assert_redirected_to root_path
  end
end
