require 'test_helper'
require 'legacy/import'

class Legacy::ImportTest < ActiveSupport::TestCase
  def legacy_seminar_data(overrides = {})
    {
      "old_id" => 42,
      "title" => "Legacy Seminar",
      "description" => "A seminar imported from the legacy system",
      "attendees_minimum" => 3,
      "attendees_maximum" => 10,
      "attendees_preconditions" => "",
      "please_bring" => "",
      "timetype" => "weekend",
      "start_date" => "2020-01-10",
      "end_date" => "2020-01-12",
      "start_time" => "10:15",
      "end_time" => "18:30",
      "alternative_dates" => "",
      "cancellation_time" => 7,
      "cancellation_reason" => "",
      "room" => "Seminarraum",
      "room_material" => "",
      "payment_royalties" => "",
      "regionalplatz" => "br",
      "time_signature" => "abc",
      "active" => "t",
      "published" => "t",
      "instructor_id" => 60,
      "uuid" => nil,
      "locked" => "f",
      "origin_id" => nil,
      "subtitle" => nil,
      "instructors" => [
        { "email" => users(:jane).email, "qualification" => "expert", "room" => "" },
      ],
    }.merge(overrides)
  end

  test "builds a Seminar from a legacy hash, combining the date and time columns" do
    seminar = Legacy::Import.seminar_from_hash(legacy_seminar_data)

    assert_kind_of Seminar, seminar
    assert_equal "Legacy Seminar", seminar.title
    assert seminar.locked
    assert_equal 10, seminar.start_date.hour
    assert_equal 15, seminar.start_date.min
    assert_equal 18, seminar.end_date.hour
    assert_equal 30, seminar.end_date.min
  end

  test "builds a seminar_instructor for every instructor with an email" do
    seminar = Legacy::Import.seminar_from_hash(legacy_seminar_data)

    assert_equal 1, seminar.seminar_instructors.size
    instructor = seminar.seminar_instructors.first
    assert_equal users(:jane).email, instructor.email
    assert_equal users(:jane), instructor.user
    assert_equal "expert", instructor.qualification
  end

  test "instructors without an email are skipped" do
    seminar = Legacy::Import.seminar_from_hash(legacy_seminar_data("instructors" => [{ "email" => nil }]))

    assert_empty seminar.seminar_instructors
  end

  test "recursively imports a nested admin_seminar and links it up" do
    seminar = Legacy::Import.seminar_from_hash(
      legacy_seminar_data("admin_seminar" => legacy_seminar_data("title" => "Admin Copy"))
    )

    assert_equal "Admin Copy", seminar.admin_seminar.title
    assert_equal seminar, seminar.admin_seminar.user_seminar
  end
end
