require 'test_helper'

class SeminarClonerTest < ActiveSupport::TestCase
  test 'it does reset the important values' do
    seminar_one = seminars(:one)
    operation   = SeminarCloner.call(seminar_one)
    copy        = operation.to_record

    refute seminar_one.locked?
    refute copy.locked?
    assert seminar_one.uuid
    refute copy.uuid
  end
end

