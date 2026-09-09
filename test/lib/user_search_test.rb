require 'test_helper'

class UserSearchTest < ActiveSupport::TestCase
  test "returns the relation unchanged when the search term is blank" do
    assert_equal User.all.to_sql, UserSearch.new(nil).apply(User.all).to_sql
    assert_equal User.all.to_sql, UserSearch.new('').apply(User.all).to_sql
  end

  test "matches email, firstname or lastname" do
    matches = UserSearch.new('Bob').apply(User.all)
    assert_includes matches, users(:bob)
    refute_includes matches, users(:jane)
  end

  test "search_model is User" do
    assert_equal User, UserSearch.new(nil).search_model
  end
end
