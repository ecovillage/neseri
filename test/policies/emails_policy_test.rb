require 'test_helper'

class EmailsPolicyTest < ActiveSupport::TestCase
  test "an admin can index and show emails" do
    policy = EmailsPolicy.new(user: users(:admin))
    assert policy.apply(:index?)
    assert policy.apply(:show?)
  end

  test "a regular user can not index or show emails" do
    policy = EmailsPolicy.new(user: users(:bob))
    refute policy.apply(:index?)
    refute policy.apply(:show?)
  end
end
