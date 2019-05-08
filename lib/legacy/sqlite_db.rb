module Legacy
  module SQLiteDB
    def self.instructor_hash legacy_data
      idx = -1
      {
        old_id:    legacy_data[idx+=1],
        firstname: legacy_data[idx+=1],
        lastname:  legacy_data[idx+=1],
        address:   legacy_data[idx+=1],
        email:     legacy_data[idx+=1],
        fax:       legacy_data[idx+=1],
        phone:     legacy_data[idx+=1],
        mobile:    legacy_data[idx+=1],
        homepage:  legacy_data[idx+=1],
        main:      legacy_data[idx+=1],
      }
    end

    def self.seminar_hash legacy_data
      idx = -1
      {
        old_id:              legacy_data[idx+=1],
        title:               legacy_data[idx+=1],
        description:         legacy_data[idx+=1],
        attendees_minimum:   legacy_data[idx+=1],
        attendees_maximum:   legacy_data[idx+=1],
        attendees_preconditions: legacy_data[idx+=1],
        please_bring:        legacy_data[idx+=1],
        timetype:            legacy_data[idx+=1],
        start_date:          legacy_data[idx+=1],
        end_date:            legacy_data[idx+=1],
        start_time:          legacy_data[idx+=1],
        end_time:            legacy_data[idx+=1],
        alternative_dates:   legacy_data[idx+=1],
        cancellation_time:   legacy_data[idx+=1],
        cancellation_reason: legacy_data[idx+=1],
        room:                legacy_data[idx+=1],
        room_material:       legacy_data[idx+=1],
        room_extras:         legacy_data[idx+=1],
        accommodation:       legacy_data[idx+=1],
        royalty_participant:  legacy_data[idx+=1],
        royalty_participant_reduced: legacy_data[idx+=1],
        material_cost:     legacy_data[idx+=1],
        honorar:           legacy_data[idx+=1],
        payment_royalties: legacy_data[idx+=1],
        regionalplatz:     legacy_data[idx+=1],
        time_signature:    legacy_data[idx+=1],
        active:        legacy_data[idx+=1],
        published:     legacy_data[idx+=1],
        instructor_id: legacy_data[idx+=1],
        uuid:          legacy_data[idx+=1],
        locked:        legacy_data[idx+=1],
        origin_id:     legacy_data[idx+=1],
        subtitle:      legacy_data[idx+=1],
      }
    end
  end
end
