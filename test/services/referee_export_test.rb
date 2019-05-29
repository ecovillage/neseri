require 'test_helper'
require 'minitest/mock'

class ExportRefereeTest < ActiveSupport::TestCase
  make_my_diffs_pretty!

  test "it can create person representations" do
    export = Legacy::PersonExport.new
    response = SecureRandom.stub :uuid, 'person_uuid' do
      export.create_person_doc seminar_instructors(:bob_and_jane_bob)
    end

    assert_equal(response, {
      _id: 'person_uuid',
      g_meta: { type: 'slseminar_person' },
      g_value: {
        firstname: 'Bob',
        lastname: 'Jones',
        email:    'bob@bob.bob',
        place: 'Bobstreet 1, 123456 Bobtown',
        zip:      '',
        address: 'Bobstreet 1, 123456 Bobtown',
        telephone: '44112244',
        cellphone: '441122441',
        fax:       '441122442',
        is_referee: true,
        homepage: 'https://bob.bob'
      }
    })
  end
end
