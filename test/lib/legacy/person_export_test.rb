require 'test_helper'
require 'minitest/mock'

class Legacy::PersonExportTest < ActiveSupport::TestCase
  test "create_person_doc builds a legacy person document from the instructor's user" do
    instructor = seminar_instructors(:bob_and_jane_bob)

    doc = Legacy::PersonExport.new.create_person_doc(instructor)

    assert doc[:_id].present?
    assert_equal 'slseminar_person', doc[:g_meta][:type]
    assert_equal instructor.user.firstname, doc[:g_value][:firstname]
    assert_equal instructor.user.lastname, doc[:g_value][:lastname]
    assert_equal instructor.user.email, doc[:g_value][:email]
    assert_equal true, doc[:g_value][:is_referee]
  end

  test "push_to_legacy PUTs the person doc to <legacy_db_uri>/<doc _id> and returns the doc id" do
    instructor = seminar_instructors(:bob_and_jane_bob)
    export = Legacy::PersonExport.new

    seen = {}
    fake_put = ->(uri, body, *_headers) {
      seen[:uri]  = uri
      seen[:body] = JSON.parse(body)
      '{"ok":true}'
    }

    result_id = RestClient.stub :put, fake_put do
      export.push_to_legacy(instructor, 'https://legacy-db.example')
    end

    assert seen[:uri].start_with?('https://legacy-db.example/')
    assert_equal result_id, seen[:uri].split('/').last
    assert_equal result_id, seen[:body]['_id']
    assert_equal instructor.user.email, seen[:body]['g_value']['email']
  end
end
