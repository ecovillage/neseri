module Legacy
  class PersonExport
    def push_to_legacy instructor, legacy_db_uri
      doc = create_person_doc instructor
      uri = legacy_db_uri + "/" + doc[:_id]
      response = RestClient.put uri, doc.to_json, {content_type: :json, accept: :json}
      doc[:_id]
    end

    def create_person_doc instructor
      {
        _id: SecureRandom.uuid,
        g_meta: { type: 'slseminar_person' },
        g_value: {
          firstname: instructor.user.firstname,
          lastname:  instructor.user.lastname,
          email:     instructor.user.email,
          place:     instructor.user.address,
          zip:       '',
          address:   instructor.user.address,
          telephone: instructor.user.phone,
          cellphone: instructor.user.mobile,
          fax:       instructor.user.fax,
          is_referee: true,
          homepage:  instructor.user.homepage
        }
      }
    end
  end
end
