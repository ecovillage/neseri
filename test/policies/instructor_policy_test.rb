require 'test_helper'

class InstructorPolicyTest < ActiveSupport::TestCase
  test "a user can show, edit, update and create their own instructor profile" do
    policy = InstructorPolicy.new(users(:jane), user: users(:jane))
    [:show?, :edit?, :update?, :create?].each do |action|
      assert policy.apply(action)
    end
  end

  test "an admin can show, edit, update and create anyone's instructor profile" do
    policy = InstructorPolicy.new(users(:jane), user: users(:admin))
    [:show?, :edit?, :update?, :create?].each do |action|
      assert policy.apply(action)
    end
  end

  test "a user can not manage someone else's instructor profile" do
    policy = InstructorPolicy.new(users(:jane), user: users(:bob))
    [:show?, :edit?, :update?, :create?].each do |action|
      refute policy.apply(action)
    end
  end
end
