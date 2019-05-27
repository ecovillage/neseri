module Legacy
  Notice = Struct.new(:text, :label, :field)

  class Export
    attr_accessor :seminar

    def initialize seminar
      @seminar          = seminar
      @seminar_doc      = nil
      @reservation_docs = {}
      @booking_docs     = {}
      @booking_person_subdocs = {}
    end

    def seminar_uuid
      @seminar_uuid ||= SecureRandom.uuid
    end

    def create_documents
      
    end

    def push
      seminar_uuid = SecureRandom.uuid
      # reservations for instructor/referees
      # bookings for instructors/referees
      # keep the uuids for later references
      # seminar
    end

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
          date_from: @seminar.start_date.strftime("%d.%m.%Y"),
          date_to:   @seminar.end_date.strftime("%d.%m.%Y"),
          time_from: @seminar.start_date.strftime("%H:%M"),
          time_to:   @seminar.end_date.strftime("%H:%M"),
        }
      }
    end

    def booking_person_doc instructor:
      @booking_person_subdocs[instructor] ||= create_booking_person_subdoc(instructor: instructor)
    end

    def create_booking_person_subdoc instructor:
      {
        l_reservation: reservation_doc(instructor: instructor).dig(:_id),
        l_person:      Publication::UserMapping.find_by(user: instructor.user).uuid,
        state:         'referee',
        role:          'referee'
      }
    end


    def booking_doc instructor:
      @booking_docs[instructor] ||= create_booking_doc(instructor: instructor)
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

    def regional_slot_booking_id
      @regional_slot_booking_id ||= regional_slot_booking_json[:_id]
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
          hidden:    true
        }
      }
    end

    def to_json
      {
        g_value: {
          title:    @seminar.title,
          subtitle: @seminar.subtitle,
          description_long:  @seminar.description,
          attendees_maximum: @seminar.attendees_maximum,
          attendees_minimum: @seminar.attendees_minimum,
          attendee_preconditions: @seminar.attendees_preconditions,
          please_bring: @seminar.please_bring,
          start_date:   @seminar.start_date.strftime("%d.%m.%Y"),
          end_date:     @seminar.end_date.strftime("%d.%m.%Y"),
          start_time:   @seminar.start_date.strftime("%H:%M"),
          end_time:     @seminar.end_date.strftime("%H:%M"),
          not_enough_attendees_cancel_date: @seminar.cancellation_time,
          not_enough_attendees_cancel_comment: @seminar.cancellation_reason,
          room:           @seminar.wished_room&.name,
          infrastructure: [@seminar.room_extras, @seminar.room_material].compact.join(", "),
          comment_attendee_housing:     @seminar.accommodation,
          cost_adult_normal_royalties:  @seminar.royalty_participant,
          cost_adult_reduced_royalties: @seminar.royalty_participant_reduced,
          cost_material:    @seminar.material_cost,
          #property :payment_royalties,    as: :cost_comment_internal
          neseri_origin_id: @seminar.id,
          regional_slot_booking_id: regional_slot_booking_id,
          # property :tour_without_regional_slot, as: :tour_without_regional_slot, :getter => lambda {|v| true }
          # property :regional_slot, as: :regional_slot, :getter => lambda {|v| true }
          cancel_conditions: "Bei Rücktritt bis 28 Tage vor Seminarbeginn: keine Rücktrittsgebühr. Bei Rücktritt 28-14 Tage vor Seminarbeginn: 50 Eur Rücktrittsgebühr pro Person. Bei Rücktritt ab dem 14. Tag vor Seminarbeginn ist der volle Teilnahmebeitrag inkl. Unterkunftskosten zu zahlen. Bei Rücktritt ab 7 Tage vor Seminarbeginn oder Nichtteilnahme ohne Abmeldung ist der volle Teilnahmebeitrag inkl. Unterkunfts- und Verpflegungskosten zu zahlen.",
          web_notice_array: web_notice_array,
          referees: seminar_referees_subdoc,
        }
      }
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
