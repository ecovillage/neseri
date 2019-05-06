class AdminSeminarCloner < Clowne::Cloner
  adapter :active_record
  include_association :seminar_instructors

  finalize do |source, record, _params|
    source.locked = true
    record.user_seminar = source
  end
end
