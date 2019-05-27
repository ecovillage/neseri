require 'test_helper'
require 'minitest/mock'

class SeminarExportTest < ActiveSupport::TestCase
  make_my_diffs_pretty!

  test "it does produce a json representation of a seminar well" do
    seminar = seminars(:one)

    export = ::Legacy::Export.new seminar
    
    template = {
      g_value: {
        title: "MySeminar",
        subtitle: "MyString",
        description_long: "MyText",
        attendees_maximum: 2,
        attendees_minimum: 1,
        attendee_preconditions: 'MyString',
        please_bring: 'MyString',
        start_date: '12.03.2019',
        end_date:   '13.03.2019',
        start_time: '20:00',
        end_time: '18:00',
        not_enough_attendees_cancel_date: 1,
        not_enough_attendees_cancel_comment: 'MyString',
        room: 'Big Room',
        infrastructure: 'Beamer, TV',
        comment_attendee_housing: 'Tent',
        cost_adult_normal_royalties: BigDecimal(250.0,2),
        cost_adult_reduced_royalties: BigDecimal(150.0,2),
        cost_material: BigDecimal(10,2),
        #property :payment_royalties,    as: :cost_comment_internal
        neseri_origin_id: seminar.id,
        regional_slot_booking_id: 'regional_slot_booking_uuid',
        # property :tour_without_regional_slot, as: :tour_without_regional_slot, :getter => lambda {|v| true }
        # property :regional_slot, as: :regional_slot, :getter => lambda {|v| true }
        cancel_conditions: 'Bei Rücktritt bis 28 Tage vor Seminarbeginn: keine Rücktrittsgebühr. Bei Rücktritt 28-14 Tage vor Seminarbeginn: 50 Eur Rücktrittsgebühr pro Person. Bei Rücktritt ab dem 14. Tag vor Seminarbeginn ist der volle Teilnahmebeitrag inkl. Unterkunftskosten zu zahlen. Bei Rücktritt ab 7 Tage vor Seminarbeginn oder Nichtteilnahme ohne Abmeldung ist der volle Teilnahmebeitrag inkl. Unterkunfts- und Verpflegungskosten zu zahlen.',
        web_notice_array: [{:text=>"Anreise Freitag 17-18 Uhr, 18:30 Abendessen", :label=>"Anreise", :field=>"arrival"}, {:text=>"Sonntag 13 Uhr Mittagessen, anschließend Abreise", :label=>"Abreise", :field=>"departure"}, {:text=>"€ (erm. €)", :label=>"Seminarkosten", :field=>"cost_seminar"}, {:text=>" €", :label=>"Biovollverpflegung", :field=>"cost_housing"}, {:text=>"Preise für Übernachtungen in Sieben Linden <a href='index.php?id=85'>hier</a>", :label=>"Unterkunft", :field=>"housing"}, {:text=>"MyString", :label=>"Voraussetzungen der TeilnehmerInnen", :field=>nil}],
        referees: []
      }
    }

    uuids = %w{regional_slot_booking_uuid uuid2 uuid3 uuid4 uuid5}
    export_response = SecureRandom.stub :uuid, lambda {uuids.shift} do
      assert_equal(export.to_json, template)
    end
  end

  test "the resentation of a seminar does include a proper referees-part" do
    seminar = seminars(:publishable)

    export = ::Legacy::Export.new seminar
    uuids = %w{regional_slot_booking_uuid uuid2 uuid3 uuid4 uuid5 uuid6}
    export_response = SecureRandom.stub :uuid, lambda {uuids.shift} do
      export.to_json
    end

    expected_referees = [
      {
        can_talk_to:   false,
        qualification: "degree",
        l_person:      "bob_uuid",
        l_reservation: "uuid3",
        l_booking:     "uuid4"
      },
      {
        can_talk_to:   true,
        qualification: nil,
        l_person:      "jane_uuid",
        l_reservation: "uuid5",
        l_booking:     "uuid6"
      }
    ]
    assert_equal(expected_referees, export_response.dig(:g_value, :referees))
  end

  test "create_documents populates all the relevant uuids and local vars" do
    seminar = seminars(:bob_and_janes_seminar)

    export = ::Legacy::Export.new seminar
    export_response = SecureRandom.stub :uuid, lambda {uuids.shift} do
      export.create_documents
    end
    skip
  end
end

