require 'test_helper'

class TermsAcceptancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "accepting the tos records when it happened" do
    user = users(:jane)
    sign_in user
    refute user.tos_accepted_at

    post terms_acceptance_path, params: { tos: true }
    assert_redirected_to root_path
    assert user.reload.tos_accepted_at
  end
end
