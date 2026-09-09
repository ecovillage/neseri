require 'test_helper'

class SeminarsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    users(:jane).update!(tos_accepted_at: DateTime.now)
  end

  test "updating with invalid data re-renders the edit form" do
    sign_in users(:jane)
    seminar = seminars(:bob_and_janes_seminar)

    patch seminar_path(seminar), params: { seminar: { title: '' } }
    assert_response :success
    refute_equal '', seminar.reload.title
  end

  # bob_and_jane_bob (fixture) has a `user` but no email/firstname/lastname/
  # address/phone - i.e. it's already invalid, sitting in the DB (fixtures
  # bypass validations on load). #update re-syncs every instructor's
  # user/email link on every save, which re-validates (and here, fails to
  # re-save) that pre-existing bad record.
  test "updating a seminar with an already-invalid instructor flashes an error but still saves" do
    sign_in users(:jane)
    seminar = seminars(:bob_and_janes_seminar)

    patch seminar_path(seminar), params: { seminar: { title: 'A new, valid title' } }
    assert_redirected_to seminar
    follow_redirect!
    assert_select '.notification', text: 'Seminarvorschlag gespeichert'
    assert_select '.notification', text: 'Könnte Referent*in nicht anlegen'
    assert_equal 'A new, valid title', seminar.reload.title
  end

  # Pagy raises Pagy::OverflowError for a page beyond the last one (e.g. a
  # stale bookmarked pagination link, or someone editing the page number
  # by hand) - left unrescued that's an unhandled exception and 500s the
  # page. NeseriController rescues it and redirects to the last valid page.
  test "an out-of-range page number redirects to the last valid page instead of 500ing" do
    sign_in users(:jane)

    get seminars_path(current_page: 999, past_page: 1)

    assert_redirected_to seminars_path(current_page: 1, past_page: 1)
    follow_redirect!
    assert_response :success
    assert_select '.notification', text: 'Diese Seite gibt es nicht (mehr) - hier ist die letzte Seite.'
  end

  test "the creator can pull a seminar back (soft-delete)" do
    sign_in users(:jane)
    seminar = seminars(:bob_and_janes_seminar)
    assert seminar.active

    delete seminar_path(seminar)
    assert_redirected_to seminars_path
    follow_redirect!
    assert_select '.notification', text: 'Seminarvorschlag zurückgezogen'
    refute seminar.reload.active
  end
end
