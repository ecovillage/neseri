require 'test_helper'

class SeminarKindTest < ActiveSupport::TestCase
  test "to_s returns the name" do
    assert_equal 'MyString', seminar_kinds(:one).to_s
  end

  test "name must be unique, case-insensitively" do
    duplicate = SeminarKind.new(name: seminar_kinds(:one).name.upcase)
    refute duplicate.valid?
    assert_includes duplicate.errors.details[:name].map { |e| e[:error] }, :taken
  end
end
