module Legacy
  module Instructors

    def self.get_for(seminar_instructor, db_uri)
      person_ids = get_person_ids_by_email(seminar_instructor.email, db_uri)
      person_ids = person_ids | get_person_ids_by_name(seminar_instructor.user.lastname, db_uri)

      person_ids.map {|id| get_person id, db_uri}
    end

    def self.get_person_ids_by_name name, db_uri
      if name.nil? || name.empty?
        []
      else
        view_uri = ''
        person_ids_from_view URI.escape("#{db_uri}/_design/sl_seminar/_view/person_by_name?key=\"#{name}\"")
      end
    end

    def self.get_person_ids_by_email email, db_uri
      if email.nil? || email.empty?
        []
      else
        person_ids_from_view URI.escape("#{db_uri}/_design/sl_seminar/_view/person_by_email?key=\"#{email}\"")
      end
    end

    def self.get_person doc_id, db_uri
      response = RestClient.get "#{db_uri}/#{doc_id}"
      row = JSON.parse(response)
      {
        id:        doc_id,
        firstname: row.dig('g_value', 'firstname'),
        lastname:  row.dig('g_value', 'lastname'),
        email:     row.dig('g_value', 'email'),
        place:     row.dig('g_value', 'place'),
        zip:       row.dig('g_value', 'zip'),
        address:   row.dig('g_value', 'address'),
        telephone: row.dig('g_value', 'telephone'),
        cellphone: row.dig('g_value', 'cellphone'),
        fax:       row.dig('g_value', 'fax'),
        homepage:  row.dig('g_value', 'homepage'),
        link:      Settings.load.legacy_web_url + '/seminar/person/edit/' + doc_id
      }
      # ?? homepage?
    end

    def self.person_ids_from_view uri
      person_docs    = RestClient.get uri
      persons_parsed = JSON.parse(person_docs)['rows']

      persons_parsed.map {|row| row['id']}
    end
  end
end
