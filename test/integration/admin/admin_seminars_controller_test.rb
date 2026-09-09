require 'test_helper'

class Admin::AdminSeminarsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can list admin-copy seminars" do
    sign_in users(:admin)

    get admin_admin_seminars_path
    assert_response :success
    assert_match seminars(:admin_copy_bob_and_janes_seminar).title, response.body
  end

  test "showing a user seminar without an admin copy notices and redirects to the user seminar" do
    sign_in users(:admin)

    get admin_admin_seminar_path(seminars(:one))
    assert_redirected_to seminars(:one)
  end

  test "showing a user seminar with an admin copy shows/redirects for that admin copy instead" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    admin_copy.update!(uuid: nil)

    get admin_admin_seminar_path(seminars(:bob_and_janes_seminar))
    assert_redirected_to edit_admin_admin_seminar_path(admin_copy)
  end

  test "showing a published admin seminar redirects to its publication page" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    admin_copy.update!(uuid: 'legacy-uuid')

    get admin_admin_seminar_path(admin_copy)
    assert_redirected_to admin_admin_seminar_publication_path(admin_copy)
  end

  test "showing an unpublished admin seminar redirects to editing it" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    admin_copy.update!(uuid: nil)

    get admin_admin_seminar_path(admin_copy)
    assert_redirected_to edit_admin_admin_seminar_path(admin_copy)
  end

  test "editing an unpublished admin seminar renders the edit form" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    admin_copy.update!(uuid: nil)

    get edit_admin_admin_seminar_path(admin_copy)
    assert_response :success
  end

  test "editing a published admin seminar redirects to showing it instead" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)
    admin_copy.update!(uuid: 'legacy-uuid')

    get edit_admin_admin_seminar_path(admin_copy)
    assert_redirected_to admin_admin_seminar_path(admin_copy)
  end

  test "an admin editing a user seminar's id is simply unauthorized (edit? is admin_and_admin_copy? only)" do
    sign_in users(:admin)

    get edit_admin_admin_seminar_path(seminars(:one))
    assert_redirected_to root_path
  end

  test "editing a user seminar's id (as its own creator) notices and redirects without erroring" do
    users(:jane).update!(tos_accepted_at: Date.today)
    sign_in users(:jane)

    get edit_admin_admin_seminar_path(seminars(:bob_and_janes_seminar))
    assert_redirected_to admin_admin_seminars_path
  end

  test "an admin can update an admin seminar" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)

    patch admin_admin_seminar_path(admin_copy), params: { seminar: { title: 'Updated Title' } }

    assert_redirected_to admin_admin_seminar_path(admin_copy)
    assert_equal 'Updated Title', admin_copy.reload.title
  end

  test "an invalid update re-renders the edit form" do
    sign_in users(:admin)
    admin_copy = seminars(:admin_copy_bob_and_janes_seminar)

    patch admin_admin_seminar_path(admin_copy), params: { seminar: { title: '' } }

    assert_response :success
    refute_equal '', admin_copy.reload.title
  end

  test "updating a user seminar's id (as its own creator) notices and redirects without erroring" do
    users(:jane).update!(tos_accepted_at: Date.today)
    sign_in users(:jane)
    seminar = seminars(:bob_and_janes_seminar)

    patch admin_admin_seminar_path(seminar), params: { seminar: { title: 'Hijacked' } }

    assert_redirected_to admin_admin_seminars_path
    refute_equal 'Hijacked', seminar.reload.title
  end
end
