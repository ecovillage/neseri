require 'test_helper'

class SeminarPolicyTest < ActiveSupport::TestCase
  test 'without user, nothing possible' do
    policy = SeminarPolicy.new(seminars(:one), user: nil)
    [:show?, :access?, :edit?].each do |action|
      refute policy.apply(action)
    end
  end

  test 'as user, can access my ownly coinstructed seminars' do
    policy = SeminarPolicy.new(seminars(:bob_and_janes_seminar), user: users(:bob))
    [:show?, :access?, :edit?].each do |action|
      assert policy.apply(action)
    end
  end

  test 'as user, can access my ownly created seminars' do
    policy = SeminarPolicy.new(seminars(:bob_and_janes_seminar), user: users(:jane))
    [:show?, :access?, :edit?].each do |action|
      assert policy.apply(action)
    end
  end

  test 'as user, can not access admin-copy seminars' do
    policy = SeminarPolicy.new(seminars(:admin_copy_bob_and_janes_seminar), user: users(:jane))
    assert policy.apply(:access?)
    refute policy.apply(:show?)
    refute policy.apply(:edit?)
  end

  test 'as admin, can see all, but not edit' do
    policy = SeminarPolicy.new(seminars(:bob_and_janes_seminar), user: users(:admin))
    [:show?, :access?].each do |action|
      assert policy.apply(action)
    end
    refute policy.apply(:edit?)
  end
end

