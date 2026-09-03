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

  # Regression test: a fresh admin copy must never inherit the source
  # seminar's uuid - otherwise it looks "already published" and the app
  # redirects straight to the publication view instead of the edit form.
  test 'a fresh admin copy has no uuid, even if the user seminar already has one' do
    seminar_one = seminars(:one)
    assert seminar_one.uuid.present?

    admin_copy = AdminSeminarCloner.call(seminar_one).to_record

    refute admin_copy.uuid.present?
  end
end
