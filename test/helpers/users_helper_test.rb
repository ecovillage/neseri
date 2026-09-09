require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test "prefers the full name when either first or last name is present" do
    assert_equal 'Full User', user_name(users(:fulluser))
  end

  test "falls back to the email when neither first nor last name is present" do
    assert_equal 'jane@jane.jane', user_name(users(:jane))
  end

  test "returns nil for a nil user" do
    assert_nil user_name(nil)
  end
end
