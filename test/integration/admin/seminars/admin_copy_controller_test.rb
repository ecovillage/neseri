require 'test_helper'

class Admin::Seminars::AdminCopyControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "creating an admin copy for a seminar that already has one just points at the existing copy" do
    sign_in users(:admin)
    user_seminar = seminars(:bob_and_janes_seminar)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)

    post admin_seminar_admin_copy_path(seminar_id: user_seminar.id)
    assert_redirected_to edit_admin_admin_seminar_path(admin_copy)
    follow_redirect!
    assert_select '.notification', text: 'Admin-Kopie besteht bereits'
  end

  test "creating an admin copy for a seminar that is itself already an admin copy is a no-op" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)

    post admin_seminar_admin_copy_path(seminar_id: admin_copy.id)
    assert_redirected_to edit_admin_admin_seminar_path(admin_copy)
    follow_redirect!
    assert_select '.notification', text: 'Ist bereits Admin-Kopie'
  end

  test "creating an admin copy for a plain user seminar creates one" do
    sign_in users(:admin)
    user_seminar = seminars(:one)
    refute user_seminar.admin_seminar

    assert_difference 'Seminar.count', 1 do
      post admin_seminar_admin_copy_path(seminar_id: user_seminar.id)
    end
    admin_copy = user_seminar.reload.admin_seminar
    assert admin_copy
    assert_redirected_to edit_admin_admin_seminar_path(admin_copy)
    follow_redirect!
    assert_select '.notification', text: 'Admin-Kopie vorbereitet'
  end
end
