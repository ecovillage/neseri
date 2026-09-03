require 'test_helper'

class CopyHelperTest < ActionView::TestCase
  test "renders nothing for a blank value" do
    assert_nil copy_icon(nil)
    assert_nil copy_icon('')
    assert_nil copy_icon('   ')
  end

  test "renders a copy icon carrying the value to copy" do
    html = copy_icon('some value')

    assert_match 'copy-icon', html
    assert_match 'data-copy="some value"', html
    assert_match 'fa-copy', html
  end

  test "escapes the value it carries" do
    html = copy_icon('<script>alert(1)</script>')

    refute_match '<script>', html
    assert_match CGI.escapeHTML('<script>alert(1)</script>'), html
  end
end
