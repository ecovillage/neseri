class FixInvalidSeminars < ActiveRecord::Migration[8.1]
  def up
    Seminar.where('attendees_minimum > attendees_maximum').each do |seminar|
      attendees_maximum_new = seminar.attendees_minimum
      seminar.attendees_minimum = seminar.attendees_maximum
      seminar.attendees_maximum = attendees_maximum_new
      seminar.save!
      puts "Switched attendee min and max counts in Seminar with ID #{seminar.id}."
    end
    Seminar.where('start_date > end_date').each do |seminar|
      end_date_new = seminar.start_date
      seminar.start_date = seminar.end_date
      seminar.end_date = end_date_new
      seminar.save!
      puts "Switched start and end dates in Seminar with ID #{seminar.id}."
    end
  end

  def down
  end
end
