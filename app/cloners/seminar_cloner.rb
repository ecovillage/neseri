class SeminarCloner < Clowne::Cloner
  adapter :active_record
  include_association :seminar_instructors

  finalize do |source, record, params|
    record.creator = params[:current_user]
    record.start_date = record.start_date.change({year: DateTime.now.year + 1})
    record.end_date = record.start_date.change({year: DateTime.now.year + 1})
    record
  end
end
