require 'test_helper'

class Admin::Seminars::LocksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can lock and unlock a seminar" do
    sign_in users(:admin)
    seminar = seminars(:one)
    refute seminar.locked

    post admin_seminar_lock_path(seminar_id: seminar.id)
    assert_redirected_to seminars_path
    follow_redirect!
    assert_select '.notification', text: 'Seminar gesperrt'
    assert seminar.reload.locked

    delete admin_seminar_lock_path(seminar_id: seminar.id)
    assert_redirected_to seminars_path
    follow_redirect!
    assert_select '.notification', text: 'Seminar entsperrt'
    refute seminar.reload.locked
  end

  test "a regular user can not lock or unlock a seminar" do
    sign_in users(:fulluser)
    seminar = seminars(:one)

    post admin_seminar_lock_path(seminar_id: seminar.id)
    assert_redirected_to root_path
    refute seminar.reload.locked
  end

  test "locking/unlocking a seminar that fails validation shows a failure notice" do
    sign_in users(:admin)
    seminar = seminars(:one)
    # Bypass validations to get an already-invalid record into the DB, so
    # the controller's own #update(locked: ...) call (which does validate)
    # fails and takes the failure branch.
    seminar.update_column(:title, nil)

    post admin_seminar_lock_path(seminar_id: seminar.id)
    assert_redirected_to seminars_path
    follow_redirect!
    assert_select '.notification', text: 'Seminar konnte nicht gesperrt werden'
    refute seminar.reload.locked

    seminar.update_column(:locked, true)
    delete admin_seminar_lock_path(seminar_id: seminar.id)
    assert_redirected_to seminars_path
    follow_redirect!
    assert_select '.notification', text: 'Seminar konnte nicht entsperrt werden'
    assert seminar.reload.locked
  end
end
