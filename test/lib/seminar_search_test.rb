require 'test_helper'

class SeminarSearchTest < ActiveSupport::TestCase
  test "returns the relation unchanged when the search term is blank" do
    assert_equal Seminar.all.to_sql, SeminarSearch.new(nil).apply(Seminar.all).to_sql
    assert_equal Seminar.all.to_sql, SeminarSearch.new('').apply(Seminar.all).to_sql
  end

  test "matches title, subtitle or description" do
    matches = SeminarSearch.new('MySeminar').apply(Seminar.all)
    assert_includes matches, seminars(:one)
    refute_includes matches, seminars(:two)
  end

  test "search_model is Seminar" do
    assert_equal Seminar, SeminarSearch.new(nil).search_model
  end
end
