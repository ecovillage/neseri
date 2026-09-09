require 'test_helper'

class InstructorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "a user can view and edit their own instructor/profile data" do
    sign_in users(:fulluser)

    get instructor_path
    assert_response :success

    get edit_instructor_path
    assert_response :success

    patch instructor_path, params: { user: { firstname: 'Changed' } }
    assert_redirected_to instructor_path
    assert_equal 'Changed', users(:fulluser).reload.firstname
  end

  test "an invalid update re-renders the edit form" do
    sign_in users(:fulluser)

    patch instructor_path, params: { user: { email: '' } }
    assert_response :success
    refute_equal '', users(:fulluser).reload.email
  end
end
