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
      instructors = seminar_data["instructors"]
      # TODO bring back timetype and room, and others
      # TODO take admin_seminar and deal with it
      ["instructors", "old_id", "timetype", "room", "payment_royalties", "regionalplatz", "time_signature", "active", "published", "instructor_id", "origin_id"].each do |key|
        seminar_data.delete(key)
      end
      start_time = seminar_data.delete "start_time"
      end_time   = seminar_data.delete "end_time"

      seminar = Seminar.new seminar_data

      start_hour, start_min = start_time.scan(/\d{2}/)
      end_hour,   end_min   = end_time.scan(/\d{2}/)
      seminar.start_date = seminar.start_date.change({hour: start_hour,
        min:  start_min})
      seminar.end_date   = seminar.end_date.change({hour: end_hour,
        min:  end_min})

      [*instructors].each do |i|
        comment = i["room"]
        seminar.seminar_instructors.build(email: i["email"], user: User.find_by(email: i["email"]), qualification: i["qualification"]) if i["email"]
      end
      seminar.save
    end

    puts "#{data["seminars"].count} Seminars created"
  end
end

