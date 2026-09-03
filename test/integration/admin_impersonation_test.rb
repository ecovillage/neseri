require 'test_helper'

class AdminImpersonationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin can impersonate another user and stop impersonating again" do
    sign_in users(:admin)

    post impersonate_admin_user_path(users(:jane))
    assert_redirected_to root_path
    follow_redirect!

    # Regression test for the "imporsonate" locale-key typo: the button
    # label used to render as "translation missing" because the view
    # called t(:impersonate) but only t(:imporsonate) was defined.
    refute_match 'translation missing', response.body
    assert_select '.navbar-item .button', text: users(:jane).email
    assert_select '.navbar-item .button', text: 'Zurück als Admin'

    post stop_impersonating_admin_users_path
    assert_redirected_to root_path
    follow_redirect!

    assert_select '.navbar-item .button', text: users(:admin).email
    refute_match 'Zurück als Admin', response.body
  end

  test "admin can not impersonate themselves" do
    sign_in users(:admin)

    post impersonate_admin_user_path(users(:admin))
    assert_redirected_to root_path
    follow_redirect!

    assert_select '.notification', text: "Du kannst dich nicht selbst als jemand anderes anmelden."
  end
end
