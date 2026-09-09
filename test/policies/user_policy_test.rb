require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  test "a user can show, edit and update their own record" do
    policy = UserPolicy.new(users(:jane), user: users(:jane))
    [:show?, :edit?, :update?].each do |action|
      assert policy.apply(action)
    end
  end

  test "an admin can show, edit and update anyone's record" do
    policy = UserPolicy.new(users(:jane), user: users(:admin))
    [:show?, :edit?, :update?].each do |action|
      assert policy.apply(action)
    end
  end

  test "a user can not show, edit or update someone else's record" do
    policy = UserPolicy.new(users(:jane), user: users(:bob))
    [:show?, :edit?, :update?].each do |action|
      refute policy.apply(action)
    end
  end

  test "an admin can list and create/index users, being an AdminPolicy" do
    policy = UserPolicy.new(users(:jane), user: users(:admin))
    assert policy.apply(:index?)

    policy = UserPolicy.new(users(:jane), user: users(:bob))
    refute policy.apply(:index?)
  end
end
