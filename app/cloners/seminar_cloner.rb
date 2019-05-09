class SeminarCloner < Clowne::Cloner
  adapter :active_record
  include_association :seminar_instructors

  finalize do |source, record, params|
    # what to do if its an admin-seminar?
    record.active = true
    record.locked = false
    record.uuid   = nil
    record.creator = params[:current_user]
    record.start_date = record.start_date.change({year: DateTime.now.year + 1})
    record.end_date = record.start_date.change({year: DateTime.now.year + 1})
    record
  end
end
