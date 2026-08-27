require 'test_helper'

class SeminarInstructorTest < ActiveSupport::TestCase
  def valid_attributes
    {
      seminar: seminars(:one),
      firstname: 'Jane',
      lastname: 'Doe',
      address: 'Musterstraße 1',
      phone: '0123456789',
      email: 'jane@example.com'
    }
  end

  test "is valid with valid attributes" do
    assert SeminarInstructor.new(valid_attributes).valid?
  end

  test "requires an email" do
    instructor = SeminarInstructor.new(valid_attributes.merge(email: nil))
    refute instructor.valid?
    assert_includes instructor.errors[:email], I18n.t('errors.messages.blank')
  end

  test "rejects emails without a real top-level domain" do
    %w[a@b a@b.c foo@bar test@localhost].each do |email|
      instructor = SeminarInstructor.new(valid_attributes.merge(email: email))
      refute instructor.valid?, "expected #{email} to be invalid"
      assert_includes instructor.errors[:email], I18n.t('errors.messages.invalid')
    end
  end

  test "accepts internationally valid email addresses" do
    %w[test@example.com m@müller.de info@москва.рф test@sub.example.co.uk].each do |email|
      instructor = SeminarInstructor.new(valid_attributes.merge(email: email))
      assert instructor.valid?, "expected #{email} to be valid, got: #{instructor.errors[:email].to_a}"
    end
  end
end
