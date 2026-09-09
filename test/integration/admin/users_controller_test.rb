require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can list and search users, split into admins and regular users" do
    sign_in users(:admin)

    get admin_users_path
    assert_response :success
    assert_select 'td', text: users(:jane).email
    assert_select 'td', text: users(:admin).email

    get admin_users_path, params: { q: users(:jane).email }
    assert_response :success
    assert_select 'td', text: users(:jane).email
    assert_select 'td', text: users(:fulluser).email, count: 0
  end

  test "an admin can show a user's details and their seminars" do
    sign_in users(:admin)

    get admin_user_path(users(:fulluser))
    assert_response :success
    assert_select 'td', text: users(:fulluser).address
  end

  test "a regular user can not list or show users" do
    sign_in users(:fulluser)

    get admin_users_path
    assert_redirected_to root_path

    get admin_user_path(users(:jane))
    assert_redirected_to root_path
  end
end
