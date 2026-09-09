require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "a homepage without a scheme gets https:// prepended, and is stripped" do
    user = users(:jane)
    user.update!(homepage: '  example.org  ')
    assert_equal 'https://example.org', user.homepage
  end

  test "a homepage that already has a scheme is left as-is" do
    user = users(:jane)
    user.update!(homepage: 'http://example.org')
    assert_equal 'http://example.org', user.homepage
  end

  test "a blank homepage is left blank" do
    user = users(:jane)
    user.update!(homepage: nil)
    assert_nil user.homepage
  end

  test "profile_missing? is true unless firstname, lastname and address are all set" do
    assert users(:jane).profile_missing?

    users(:jane).assign_attributes(firstname: 'Jane', lastname: 'Doe', address: 'Somewhere 1')
    refute users(:jane).profile_missing?
  end
end
