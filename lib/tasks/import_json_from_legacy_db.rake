namespace :neseri do
  desc 'create users from email data in legacy database'

  task import_legacy_json: :environment do
    require 'legacy/import'

    data = JSON.load(File.read('neseri_legacy.json'))

    # timetype:
    # weekend
    # inweek
    # day

    # -> migrate: room_comment(room)
    instructor_user_id_map = {}

    # Instructors were actually Users
    data["instructors"].select{|i| i.to_s != '' }.each do |orig_instructor_data|
      instructor_data = orig_instructor_data.clone
      old_id = instructor_data["old_id"]

      ["qualification", "room", "saraswati_id", "contact_person", "old_id", "main"].each do |key|
        instructor_data.delete key
      end
      user = User.find_or_initialize_by(instructor_data)

      generated_password = Devise.friendly_token.first(8)
      instructor_data["password"]              = generated_password
      instructor_data["password_confirmation"] = generated_password
      instructor_data["tos_agreement"]         = true
      instructor_data["confirmed_at"]          = DateTime.now

      if user.update(instructor_data)
        user.tos_accepted_at = nil
        user.save!
        instructor_user_id_map[old_id] = user
      else
        puts user.errors.inspect
      end
    end

    # Merge in info from dirty data
    data["instructors"].select{|i| i.to_s == '' }.each do |instructor_data|
      ["old_id"].each do |key|
        instructor_data.delete key
      end
      # 
    end

    data["seminars"].each do |seminar_data|
      seminar = Legacy::Import.seminar_from_hash seminar_data
      seminar.save
    end

    puts "#{data["seminars"].count} Seminars created"
  end
end

