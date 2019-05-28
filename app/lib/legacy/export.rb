module Legacy
  Notice = Struct.new(:text, :label, :field)
  TIME_FMT = '%H:%M'
  DATE_FMT = '%d.%m.%Y'

  # Push seminar to legacy database (couchdb)
  class Export
    attr_accessor :seminar

    def initialize seminar
      @seminar          = seminar
      @seminar_doc      = nil
      @reservation_docs = {}
      @booking_docs     = {}
      @booking_person_subdocs = {}
    end

    def push legacy_db_uri
      regional_slot_json = regional_slot_booking_json

      seminar_json = to_json

      (@booking_docs.values | @reservation_docs.values | [seminar_json, regional_slot_json]).map do |doc|
        uri = legacy_db_uri + "/" + doc[:_id]
        response = RestClient.put uri, doc.to_json, {content_type: :json, accept: :json}
        puts "pushed: #{response}"
        response
      end
    end

    # TODO infrastructure, housing
    def to_json
      {
        _id: seminar_uuid,
        g_meta: { type: 'slseminar_seminar' },
        g_value: {
          title:    @seminar.title,
          subtitle: @seminar.subtitle,
          description_long:  @seminar.description,
          attendees_maximum: @seminar.attendees_maximum,
          attendees_minimum: @seminar.attendees_minimum,
          attendee_preconditions: @seminar.attendees_preconditions,
          please_bring: @seminar.please_bring,
          date_from:    @seminar.start_date.strftime(DATE_FMT),
          date_to:      @seminar.end_date.strftime(DATE_FMT),
          start_time:   @seminar.start_date.strftime(TIME_FMT),
          end_time:     @seminar.end_date.strftime(TIME_FMT),
          not_enough_attendees_cancel_date: @seminar.cancellation_time,
          not_enough_attendees_cancel_comment: @seminar.cancellation_reason,
          room:           @seminar.wished_room&.name,
          reserved_from:  (@seminar.start_date - 1.hours).strftime("#{DATE_FMT} #{TIME_FMT}"),
          reserved_to:    (@seminar.end_date   + 1.hours).strftime("#{DATE_FMT} #{TIME_FMT}"),
          infrastructure: [@seminar.room_extras, @seminar.room_material].compact.join(", "),
          comment_attendee_housing:     @seminar.accommodation,
          cost_adult_normal_royalties:  @seminar.royalty_participant,
          cost_adult_reduced_royalties: @seminar.royalty_participant_reduced,
          cost_material:    @seminar.material_cost,
          #property :payment_royalties,    as: :cost_comment_internal
          neseri_origin_id: @seminar.id,
          regional_slot_booking_id: regional_slot_booking_uuid,
          regional_slot: true,
          # property :tour_without_regional_slot, as: :tour_without_regional_slot, :getter => lambda {|v| true }
          cancel_conditions: "Bei Rücktritt bis 28 Tage vor Seminarbeginn: keine Rücktrittsgebühr. Bei Rücktritt 28-14 Tage vor Seminarbeginn: 50 Eur Rücktrittsgebühr pro Person. Bei Rücktritt ab dem 14. Tag vor Seminarbeginn ist der volle Teilnahmebeitrag inkl. Unterkunftskosten zu zahlen. Bei Rücktritt ab 7 Tage vor Seminarbeginn oder Nichtteilnahme ohne Abmeldung ist der volle Teilnahmebeitrag inkl. Unterkunfts- und Verpflegungskosten zu zahlen.",
          web_notice_array: web_notice_array,
          referees: seminar_referees_subdoc,
        }
      }
    end
    
    def seminar_uuid
      @seminar_uuid ||= SecureRandom.uuid
    end

    def seminar_referees_subdoc
      @seminar.seminar_instructors.map do |instructor|
        {
          can_talk_to:   instructor.contactable,
          qualification: instructor.qualification,
          l_person:      Publication::UserMapping.find_by(user: instructor.user.id).uuid,
          l_reservation: reservation_doc(instructor: instructor).dig(:_id),
          l_booking:     booking_doc(instructor: instructor).dig(:_id)
        }
      end
    end

    def reservation_doc instructor
      @reservation_docs[instructor] ||= create_reservation_doc
    end

    def booking_person_doc instructor:
      @booking_person_subdocs[instructor] ||= create_booking_person_subdoc(instructor: instructor)
    end

    def booking_doc instructor:
      @booking_docs[instructor] ||= create_booking_doc(instructor: instructor)
    end

    def regional_slot_booking_uuid
      @regional_slot_booking_uuid ||= regional_slot_booking_json[:_id]
    end

    def regional_slot_booking_json
      return @regional_slot_booking if @regional_slot_booking

      uuid = SecureRandom.uuid
      @regional_slot_booking = {
        _id: uuid,
        g_meta: {
          type: 'slseminar_booking'
        },
        g_value: {
          l_seminar: seminar_uuid,
          nodelete:  true,
          regional_slot: true,
          hidden:    true,
          persons:   []
        }
      }
    end

    private

    def create_reservation_doc
      uuid = SecureRandom.uuid
      {
        _id: uuid,
        g_meta: {
          type: 'slseminar_reservation'
        },
        g_value: {
          #property :l_room
          #property :comments
          date_from: @seminar.start_date.strftime(DATE_FMT),
          date_to:   @seminar.end_date.strftime(DATE_FMT),
          time_from: @seminar.start_date.strftime(TIME_FMT),
          time_to:   @seminar.end_date.strftime(TIME_FMT),
        }
      }
    end

    def create_booking_person_subdoc instructor:
      {
        l_reservation: reservation_doc(instructor: instructor).dig(:_id),
        l_person:      Publication::UserMapping.find_by(user: instructor.user).uuid,
        state:         'referee',
        role:          'referee'
      }
    end

    def create_booking_doc instructor:
      uuid = SecureRandom.uuid
      {
        _id: uuid,
        g_meta: {
          type: 'slseminar_booking'
        },
        g_value: {
          l_seminar: seminar_uuid,
          persons:   [booking_person_doc(instructor: instructor)]
        }
      }
    end

    def web_notice_array
      notices = 
        [ Notice.new('Anreise Freitag 17-18 Uhr, 18:30 Abendessen', 'Anreise', 'arrival'),
          Notice.new('Sonntag 13 Uhr Mittagessen, anschließend Abreise', 'Abreise', 'departure'),
          Notice.new("€ (erm. €)", 'Seminarkosten', 'cost_seminar'),
          Notice.new(" €", 'Biovollverpflegung', 'cost_housing'),
          Notice.new("Preise für Übernachtungen in Sieben Linden <a href='index.php?id=85'>hier</a>", 'Unterkunft', 'housing')
        ]
      if @seminar.attendees_preconditions && !@seminar.attendees_preconditions.empty?
        notices << Notice.new(@seminar.attendees_preconditions, "Voraussetzungen der TeilnehmerInnen")
      end
      notices.map {|n| Hash[n.each_pair.to_a]}
    end
  end
end
