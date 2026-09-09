require 'test_helper'
require 'minitest/mock'

class Legacy::InstructorsTest < ActiveSupport::TestCase
  test "get_for looks a person up by email and by lastname, and fetches each match" do
    # SeminarInstructor#set_user re-links to whichever User matches the given
    # email, so the linked user (whose lastname get_for also looks up by)
    # has to actually exist under that address.
    user = User.create!(email: 'bob@example.com', password: 'password123', password_confirmation: 'password123',
      firstname: 'Bob', lastname: 'Jones', phone: '441122', tos_agreement: true)

    seminar_instructor = seminar_instructors(:bob_and_jane_bob)
    seminar_instructor.update!(email: user.email, firstname: 'Bob', lastname: 'Jones',
      address: 'Bobstreet 1', phone: '441122')

    Setting.find_or_create_by(key: 'legacy_web_url').update!(value: 'https://legacy.example')

    view_response = { 'rows' => [{ 'id' => 'doc-1' }] }.to_json
    person_response = {
      'g_value' => { 'firstname' => 'Bob', 'lastname' => 'Jones', 'email' => 'bob@bob.bob' },
    }.to_json

    seen_uris = []
    fake_get = ->(uri, *_rest) {
      seen_uris << uri
      uri.include?('doc-1') ? person_response : view_response
    }

    result = RestClient.stub :get, fake_get do
      Legacy::Instructors.get_for(seminar_instructor, 'https://legacy-db.example')
    end

    assert_equal 1, result.size
    assert_equal 'doc-1', result.first[:id]
    assert_equal 'Bob', result.first[:firstname]
    assert_equal 'https://legacy.example/seminar/person/edit/doc-1', result.first[:link]

    assert seen_uris.any? { |uri| uri.include?('person_by_email') }
    assert seen_uris.any? { |uri| uri.include?('person_by_name') }
  end

  test "get_person_ids_by_name and get_person_ids_by_email return [] for blank input" do
    assert_equal [], Legacy::Instructors.get_person_ids_by_name(nil, 'https://legacy-db.example')
    assert_equal [], Legacy::Instructors.get_person_ids_by_name('', 'https://legacy-db.example')
    assert_equal [], Legacy::Instructors.get_person_ids_by_email(nil, 'https://legacy-db.example')
    assert_equal [], Legacy::Instructors.get_person_ids_by_email('', 'https://legacy-db.example')
  end
end
