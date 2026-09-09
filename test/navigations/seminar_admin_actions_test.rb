require 'test_helper'

class SeminarAdminActionsTest < ActiveSupport::TestCase
  test "items is empty without a seminar or a user" do
    assert_equal [], SeminarAdminActions.new(nil, users(:admin)).items
    assert_equal [], SeminarAdminActions.new(seminars(:one), nil).items
  end

  test "a user seminar without an admin copy offers to create one, and to lock it" do
    seminar = seminars(:one)
    items = SeminarAdminActions.new(seminar, users(:admin)).items

    titles = items.map(&:title)
    assert_includes titles, I18n.t("seminar.create_admin_copy")
    assert_includes titles, I18n.t(:lock)
    refute_includes titles, I18n.t(:edit)
    refute_includes titles, I18n.t("seminar.view_user_version")
    refute_includes titles, I18n.t("seminar.publish")
  end

  test "a user seminar that already has an admin copy offers to view it, and to unlock it once locked" do
    seminar = seminars(:bob_and_janes_seminar)
    items = SeminarAdminActions.new(seminar, users(:admin)).items

    titles = items.map(&:title)
    assert_includes titles, I18n.t("seminar.view_admin_copy")
    assert_includes titles, I18n.t(:lock)

    seminar.locked = true
    items = SeminarAdminActions.new(seminar, users(:admin)).items
    assert_includes items.map(&:title), I18n.t(:unlock)
  end

  test "an unpublished admin copy offers to edit it, view its user version, and publish it" do
    seminar = seminars(:admin_copy_bob_and_janes_seminar)
    items = SeminarAdminActions.new(seminar, users(:admin)).items

    titles = items.map(&:title)
    assert_includes titles, I18n.t(:edit)
    assert_includes titles, I18n.t("seminar.view_user_version")
    assert_includes titles, I18n.t("seminar.publish")
  end

  test "an inactive user seminar is not offered locking" do
    seminar = seminars(:one)
    seminar.active = false
    items = SeminarAdminActions.new(seminar, users(:admin)).items

    titles = items.map(&:title)
    refute_includes titles, I18n.t(:lock)
    refute_includes titles, I18n.t(:unlock)
  end
end
