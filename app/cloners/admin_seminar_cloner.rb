class AdminSeminarCloner < Clowne::Cloner
  adapter :active_record
  include_association :seminar_instructors

  # A fresh admin copy is never already published to the legacy system -
  # without this it would inherit the user seminar's uuid (once that one
  # has been published), and immediately redirect to the publication view
  # instead of the edit form.
  nullify :uuid

  finalize do |source, record, _params|
    source.locked = true
    record.user_seminar = source
  end
end
