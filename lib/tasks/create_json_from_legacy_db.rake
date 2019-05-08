#{:seminars=>
#  [{:old_id=>1,
#    :title=>"Seminartitel",
#    :description=>"Beschreibung des Seminars",
#    :attendees_minimum=>7,
#    :attendees_maximum=>18,
#    :attendees_preconditions=>"",
#    :please_bring=>"",
#    :timetype=>"weekend",
#    :start_date=>"2015-03-23",
#    :end_date=>"2015-04-1",
#    :start_time=>"10:00",
#    :end_time=>"18:00",
#    :alternative_dates=>"auch im Sommer möglich",
#    :cancellation_time=>7,
#    :cancellation_reason=>"",
#    :room=>"Seminarraum",
#    :room_material=>"",
#    :room_extras=>"",
#    :accommodation=>"Gästezimmer",
#    :royalty_participant=>70.0,
#    :royalty_participant_reduced=>50.0,
#    :material_cost=>0.0,
#    :honorar=>nil,
#    :payment_royalties=>"",
#    :regionalplatz=>"br",
#    :time_signature=>"abc",
#    :active=>"t",
#    :published=>"t",
#    :instructor_id=>60,
#    :uuid=>"5d73fb31-b38e-452f-873e-03b673ca4886",
#    :locked=>"f",
#    :origin_id=>nil,
#    :subtitle=>nil,
#    :instructors=>
#     [{:old_id=>60,
#       :firstname=>"Felix",
#       :lastname=>"Wolfsteller",
#       :address=>"",
#       :email=>"felix.wolfsteller@email",
#       :fax=>"",
#       :phone=>"08910283",
#       :mobile=>"",
#       :homepage=>"",
#       :main=>"t",
#       :qualification=>"",
#       :room=>"",
#       :saraswati_id=>nil,
#       :contact_person=>"f"},
#      {:old_id=>2,
#       :firstname=>"Hansa",
#       :lastname=>"Wolfsteller",
#       :address=>"",
#       :email=>"hansa@email",
#       :fax=>"",
#       :phone=>"9809322",
#       :mobile=>"",
#       :homepage=>"",
#       :main=>"f",
#       :qualification=>"",
#       :room=>"",
#       :saraswati_id=>nil,
#       :contact_person=>nil}]},

namespace :neseri do
  desc 'create users and other data from data in legacy sqlite3 database'

  task create_legacy_json: :environment do
    require 'legacy/sqlite_db'
    require 'sqlite3'
    db = SQLite3::Database.new "neseri_legacy.db"

    #CREATE TABLE IF NOT EXISTS "instructors" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "firstname" VARCHAR(255) NOT NULL, "lastname" VARCHAR(255) NOT NULL, "adress" VARCHAR(255), "email" VARCHAR(255), "fax" VARCHAR(255), "phone" VARCHAR(255), "mobile" VARCHAR(255), "homepage" VARCHAR(255), "main" BOOLEAN DEFAULT 'f');
    instructor_data = []
    db.execute("SELECT * FROM instructors") do |row|
      instructor_data << Legacy::SQLiteDB.instructor_hash(row)
    end

    # clean up data
    no_mail = instructor_data.select {|i| i[:email].to_s == ''}

    # seminars with instructors

    #CREATE TABLE IF NOT EXISTS "seminars" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" VARCHAR(256), "description" TEXT, "attendees_minimum" INTEGER, "attendees_maximum" INTEGER, "attendee_preconditions" VARCHAR(255), "please_bring" VARCHAR(255), "timetype" VARCHAR(255), "start_date" DATE, "end_date" DATE, "start_time" VARCHAR(255) NOT NULL, "end_time" VARCHAR(255) NOT NULL, "alternative_dates" TEXT, "cancellation_time" INTEGER DEFAULT 7, "cancellation_reason" TEXT, "room" VARCHAR(255), "room_material" VARCHAR(255), "room_extras" VARCHAR(255), "participants_housing" VARCHAR(255) DEFAULT 'Gästezimmer', "royalty_participant" FLOAT, "royalty_participant_reduced" FLOAT, "material_cost" FLOAT DEFAULT 0.0, "honorar" FLOAT, "payment_royalties" VARCHAR(255), "regionalplatz" VARCHAR(255), "time_signature" VARCHAR(255) NOT NULL, "active" BOOLEAN DEFAULT 't', "published" BOOLEAN DEFAULT 'f', "instructor_id" INTEGER NOT NULL, "uuid" VARCHAR(255), "locked" BOOLEAN DEFAULT 'f', "origin_id" VARCHAR(255), "subtitle" VARCHAR(256));
    seminar_data = []
    db.execute("SELECT * FROM seminars;").each do |row|
      next if row == '\'' # TODO remove

      instructors = [instructor_data.find{|id| id[:old_id] == row[28] }].compact

      seminar = Legacy::SQLiteDB.seminar_hash(row)
      seminar[:instructors] = instructors
      seminar_data << seminar
    end

    # co-instructions
    #CREATE TABLE IF NOT EXISTS "seminar_co_instructions" ("seminar_id" INTEGER NOT NULL, "instructor_id" INTEGER NOT NULL, PRIMARY KEY("seminar_id", "instructor_id"));
    db.execute("SELECT * FROM seminar_co_instructions;").each do |row|
      seminar_id    = row[0]
      instructor_id = row[1]
      
      seminar    = seminar_data.find{|sd| sd[:old_id] == seminar_id}
      instructor = instructor_data.find{|id| id[:old_id] == instructor_id }
      if seminar && instructor
        # TODO seminar[:instructors] ||= []
        seminar[:instructors] << instructor
      else
        STDERR.puts "co-instruction failed"
      end
    end


    # qualifications
    # CREATE TABLE IF NOT EXISTS "qualifications" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "text" TEXT, "contact_person" BOOLEAN, "room" VARCHAR(255), "instructor_id" INTEGER NOT NULL, "seminar_id" INTEGER NOT NULL, "saraswati_instructor_docid" VARCHAR(255));
    db.execute("SELECT * FROM qualifications;").each do |row|
      idx = -1

      old_id         = row[idx+=1]
      qualification  = row[idx+=1]
      contact_person = row[idx+=1]
      room           = row[idx+=1]
      instructor_id  = row[idx+=1]
      seminar_id     = row[idx+=1]
      saraswati_id   = row[idx+=1]

      seminar    = seminar_data.find{|sd| sd[:old_id] == seminar_id}
      instructor = seminar[:instructors]&.find{|i| i[:old_id] == instructor_id}
      if seminar && instructor
        instructor[:qualification]  = qualification
        instructor[:room]           = room
        instructor[:saraswati_id]   = saraswati_id
        instructor[:contact_person] = contact_person
        STDERR.puts "could add qualification!!!"
        # Add it again?
      else
        STDERR.puts "could not add qualification"
      end
    end

    # Skip categories
    # CREATE TABLE IF NOT EXISTS "categories" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" VARCHAR(255), "language" VARCHAR(255));

    json = {seminars:    seminar_data,
            instructors: instructor_data}.to_json
    puts json
  end
end
