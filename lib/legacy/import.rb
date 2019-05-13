module Legacy
  module Import
    def self.seminar_from_hash seminar_data
      instructors = seminar_data["instructors"]
      # TODO bring back timetype and room, and others

      ["instructors", "old_id", "timetype", "room", "payment_royalties", "regionalplatz", "time_signature", "active", "published", "instructor_id", "origin_id"].each do |key|
        seminar_data.delete(key)
      end

      admin_seminar_data = seminar_data.delete('admin_seminar')
      if admin_seminar_data
        admin_seminar = seminar_from_hash admin_seminar_data
        # We know this can't loop.
      end

      start_time = seminar_data.delete "start_time"
      end_time   = seminar_data.delete "end_time"

      seminar = Seminar.new seminar_data
      seminar.locked = true

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

      if admin_seminar
        seminar.admin_seminar = admin_seminar
      end

      seminar
    end
  end
end
