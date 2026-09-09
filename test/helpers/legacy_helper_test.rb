require 'test_helper'

class LegacyHelperTest < ActionView::TestCase
  test "builds the legacy edit url from the given settings' legacy_web_url and the seminar's uuid" do
    seminar = seminars(:one)
    seminar.uuid = 'the-uuid'
    settings = Settings.new(legacy_web_url: 'https://legacy.example')

    assert_equal 'https://legacy.example/seminar/seminar/edit/the-uuid', legacy_web_url(seminar, settings)
  end

  test "loads the settings when none are given" do
    Setting.find_or_create_by(key: 'legacy_web_url').update!(value: 'https://loaded.example')
    seminar = seminars(:one)
    seminar.uuid = 'the-uuid'

    assert_equal 'https://loaded.example/seminar/seminar/edit/the-uuid', legacy_web_url(seminar)
  end
end
