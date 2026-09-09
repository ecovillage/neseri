require 'test_helper'

class Admin::SeminarKindsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can list, create, deactivate and reactivate seminar kinds" do
    sign_in users(:admin)

    get admin_seminar_kinds_path
    assert_response :success
    assert_match seminar_kinds(:one).name, response.body

    get new_admin_seminar_kind_path
    assert_response :success

    assert_difference 'SeminarKind.count', 1 do
      post admin_seminar_kinds_path, params: { seminar_kind: { name: 'New Kind', description: 'desc' } }
    end
    assert_redirected_to admin_seminar_kinds_path
    kind = SeminarKind.find_by(name: 'New Kind')
    assert kind.active

    patch admin_seminar_kind_path(kind)
    assert_redirected_to admin_seminar_kinds_path
    refute kind.reload.active

    active_kind = SeminarKind.create!(name: 'Active Kind', active: true)
    delete admin_seminar_kind_path(active_kind)
    assert_redirected_to admin_seminar_kinds_path
    refute active_kind.reload.active
  end

  test "creating a seminar_kind with a duplicate name re-renders the form" do
    sign_in users(:admin)

    post admin_seminar_kinds_path, params: { seminar_kind: { name: seminar_kinds(:one).name } }
    assert_response :success
  end

  test "a regular user can not manage seminar kinds" do
    sign_in users(:fulluser)

    get admin_seminar_kinds_path
    assert_redirected_to root_path

    post admin_seminar_kinds_path, params: { seminar_kind: { name: 'Nope' } }
    assert_redirected_to root_path
    refute SeminarKind.exists?(name: 'Nope')
  end
end
