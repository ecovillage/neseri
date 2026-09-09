require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "accepting an invitation with the tos checkbox unchecked re-renders the form with an error" do
    user = User.invite!(email: 'referent@example.com', firstname: 'Ref', lastname: 'Erent', phone: '12345')
    token = user.raw_invitation_token

    put user_invitation_path, params: {
      user: { invitation_token: token, password: 'password123', password_confirmation: 'password123' },
    }

    assert_response :success
    refute user.reload.invitation_accepted_at
  end

  test "accepting an invitation with the checkbox checked signs the user in" do
    user = User.invite!(email: 'referent@example.com', firstname: 'Ref', lastname: 'Erent', phone: '12345')
    token = user.raw_invitation_token

    put user_invitation_path, params: {
      user: { invitation_token: token, password: 'password123', password_confirmation: 'password123', tos_agreement: '1' },
    }

    assert_response :redirect
    assert user.reload.invitation_accepted_at
    assert user.tos_accepted_at
  end

  # This is the actual 500 that got fixed: an invitation link is only valid
  # once - accepting it clears the token in the DB. A second submission
  # using the *same* token from an unauthenticated session (a second
  # browser/tab/device that had the invitation form open, a resubmit via
  # the back button, ...) used to crash with
  # `NoMethodError: undefined method 'update' for nil` instead of showing
  # an error, because the resource lookup returned nil for an unmatched
  # token and both branches of #update called methods on it
  # unconditionally.
  test "submitting an already-used invitation token from a second session shows an error instead of 500ing" do
    user = User.invite!(email: 'referent@example.com', firstname: 'Ref', lastname: 'Erent', phone: '12345')
    token = user.raw_invitation_token

    put user_invitation_path, params: {
      user: { invitation_token: token, password: 'password123', password_confirmation: 'password123', tos_agreement: '1' },
    }
    assert user.reload.invitation_accepted_at
    assert_nil user.invitation_token

    open_session do |second_session|
      second_session.put second_session.user_invitation_path, params: {
        user: { invitation_token: token, password: 'password123', password_confirmation: 'password123', tos_agreement: '1' },
      }

      assert_response :redirect
      second_session.follow_redirect!
      assert_match 'Der Einladungslink ist ungültig', second_session.response.body
    end
  end
end
