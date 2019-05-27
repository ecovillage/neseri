require 'test_helper'
require 'minitest/mock'

class ExportBookingTest < ActiveSupport::TestCase
  test "it does produce a json representation for person entry in bookings" do
    seminar_instructor = seminar_instructors(:bob_and_jane_bob)
    export = ::Legacy::Export.new seminars(:one)
    uuid   = SecureRandom.uuid

    export_response = SecureRandom.stub :uuid, uuid do
      assert_equal({l_reservation: uuid,
                    l_person: 'bob_uuid',
                    state:    'referee',
                    role:     'referee'},
        export.booking_person_doc(instructor: seminar_instructor))
    end
  end

  test "it does produce a json representation for needed bookings" do
    seminar           = seminars(:bob_and_janes_seminar)
    seminar_instructor= seminar_instructors(:bob_and_jane_jane)
    seminar_uuid     = 'seminar_uuid'
    reservation_uuid = 'reservation_uuid'

    export = ::Legacy::Export.new seminar

    uuids = %w{booking_uuid seminar_uuid reservation_uuid}
    export_response = SecureRandom.stub :uuid, lambda {uuids.shift} do
      export.booking_doc(instructor: seminar_instructor)
    end

    asserted_response = {
      _id: 'booking_uuid',
      g_meta:  { type: 'slseminar_booking' },
      g_value: {
        l_seminar: 'seminar_uuid',
        persons:  [{
          l_reservation: 'reservation_uuid',
          l_person:      'jane_uuid',
          state:         'referee',
          role:          'referee'}],
      }
    }

    assert_equal(asserted_response, export_response)
  end

  test "it does produce a regional slot" do
    seminar           = seminars(:bob_and_janes_seminar)
    seminar_uuid     = 'seminar_uuid'

    export = ::Legacy::Export.new seminar
    asserted_response = {
      _id:     'regional_slot_booking_uuid',
      g_meta:  { type: 'slseminar_booking' },
      g_value: {
        l_seminar: 'seminar_uuid',
        nodelete: true,
        hidden:   true,
        regional_slot: true
      }
    }

    uuids = %w{seminar_uuid regional_slot_booking_uuid}
    export_response = SecureRandom.stub :uuid, lambda {uuids.pop} do
      export.regional_slot_booking_json
    end

    assert_equal asserted_response, export_response
  end
end
