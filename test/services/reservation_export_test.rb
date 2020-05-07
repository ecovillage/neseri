require 'test_helper'
require 'minitest/mock'

class ReservationExportTest < ActiveSupport::TestCase
  test "it does produce a json representation for needed reservations" do
    seminar = seminars(:one)
    export = ::Legacy::Export.new seminar

    SecureRandom.stub :uuid, 'reservation_uuid' do
      assert_equal({
        _id: 'reservation_uuid',
        g_meta:  { type: 'slseminar_reservation' },
        g_value: {
          date_from: '12.03.2019',
          date_to:   '13.03.2019',
          time_from: '20:00',
          time_to:   '18:00'
        }
      }, export.reservation_doc(nil))
    end

    seminar = seminars(:bob_and_janes_seminar)
    export = ::Legacy::Export.new seminar

    next_year = DateTime.current.year + 1

    asserted_response = [
      {:_id    =>"uuid3",
       :g_meta =>{:type=>"slseminar_reservation"},
       :g_value=>{:date_from=>"20.01.#{next_year}", :date_to=>"22.01.#{next_year}", :time_from=>"20:30", :time_to=>"13:00"}},
      {:_id=>"uuid2",
       :g_meta =>{:type=>"slseminar_reservation"},
       :g_value=>{:date_from=>"20.01.#{next_year}", :date_to=>"22.01.#{next_year}", :time_from=>"20:30", :time_to=>"13:00"}},
      {:_id=>"uuid1",
       :g_meta =>{:type=>"slseminar_reservation"},
       :g_value=>{:date_from=>"20.01.#{next_year}", :date_to=>"22.01.#{next_year}", :time_from=>"20:30", :time_to=>"13:00"}}
    ].first

    # TODO: we just test a single reservation (first) and ignore room and comment thus far.

    uuids = %w{uuid1 uuid2 uuid3}
    SecureRandom.stub :uuid, lambda {uuids.pop} do
      assert_equal(asserted_response, export.reservation_doc(nil))
    end
  end
end
