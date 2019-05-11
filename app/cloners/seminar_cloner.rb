class SeminarCloner < Clowne::Cloner
  adapter :active_record
  include_association :seminar_instructors
  #include_attached :files

  nullify :uuid

  finalize do |source, record, params|
    # What to do if its an admin-seminar? raise?

    record.creator = params[:current_user]

    record.active  = true
    record.locked  = false
    record.start_date = record.start_date.change({year: DateTime.now.year + 1})
    record.end_date   = record.start_date.change({year: DateTime.now.year + 1})
    record
  end
end
