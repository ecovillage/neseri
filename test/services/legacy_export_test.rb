require 'test_helper'
require 'minitest/mock'

class LegacyExportTest < ActiveSupport::TestCase
  test "it does memoize relevant stuff" do
    seminar = seminars(:bob_and_janes_seminar)
    export  = Legacy::Export.new(seminar)
    first_uuid = export.seminar_uuid
    assert_equal first_uuid, export.seminar_uuid

    first_regional_slot = export.regional_slot_booking_json
    assert_equal first_regional_slot, export.regional_slot_booking_json
  end
end
