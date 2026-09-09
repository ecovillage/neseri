require 'test_helper'

class Admin::Seminars::SearchControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can search seminars by title" do
    sign_in users(:admin)

    get search_admin_seminars_path, params: { q: 'Bob and Jane save' }
    assert_response :success
    assert_select 'a', text: seminars(:bob_and_janes_seminar).title
    assert_select 'a', text: seminars(:one).title, count: 0
  end

  test "a regular user can not search seminars" do
    sign_in users(:fulluser)

    get search_admin_seminars_path, params: { q: 'Bob' }
    assert_redirected_to root_path
  end
end
