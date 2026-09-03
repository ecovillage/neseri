require 'test_helper'

class SeminarShowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "line breaks in the description are shown as <br>, and unsafe tags are neutralized" do
    seminar = seminars(:one)
    seminar.update!(description: "Line one\nLine two\n<script>alert(1)</script>")

    sign_in users(:admin)
    get seminar_path(seminar)
    assert_response :success

    assert_select 'td', text: /Line one\s*Line two/
    assert_select 'td br', count: 2

    # simple_format sanitizes the input, so the <script> tag itself is
    # stripped (not merely displayed as text) - either way, no live
    # <script> tag may reach the page.
    assert_select 'script', text: 'alert(1)', count: 0
    assert_no_match(/<script[^>]*>alert\(1\)/, response.body)
  end
end
