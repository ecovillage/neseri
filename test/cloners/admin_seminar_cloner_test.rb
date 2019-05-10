require 'test_helper'

class AdminSeminarClonerTest < ActiveSupport::TestCase
  test 'it does correlate the two seminars' do
    seminar_one = seminars(:one)
    operation = AdminSeminarCloner.call(seminar_one)
    admin_copy = operation.to_record

    assert seminar_one.locked?
    assert admin_copy.user_seminar == seminar_one
    assert admin_copy.is_admin_seminar?
    assert seminar_one.admin_seminar == admin_copy
  end
end
