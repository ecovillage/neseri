# SPDX-FileCopyrightText: 2020 Felix Wolfsteller
#
# SPDX-License-Identifier: AGPL-3.0-or-later

require 'test_helper'

class PageVisitTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "anonymous can visit privacy and terms pages" do
    get privacy_path
    assert_response :success

    assert_select '.title', text: 'Datenschutzerklärung'
  end

  test "logged in user sees acceptance on privacy and terms pages" do
    sign_in users(:fulluser)

    get privacy_path
    assert_response :success

    #assert_equal response.parsed_body, ''

    assert_select '.has-text-centered', text: /zugestimmt am/
  end
end
