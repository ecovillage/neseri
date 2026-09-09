require 'test_helper'

class SettingsTest < ActiveSupport::TestCase
  test "load reads existing legacy_db_uri and legacy_web_url settings" do
    Setting.create!(key: 'legacy_db_uri', value: 'https://db.example')
    Setting.create!(key: 'legacy_web_url', value: 'https://web.example')

    settings = Settings.load

    assert_equal 'https://db.example', settings.legacy_db_uri
    assert_equal 'https://web.example', settings.legacy_web_url
  end

  test "load creates the settings (with a nil value) if they don't exist yet" do
    refute Setting.exists?(key: 'legacy_db_uri')

    settings = Settings.load

    assert Setting.exists?(key: 'legacy_db_uri')
    assert_nil settings.legacy_db_uri
  end

  test "save persists legacy_db_uri and legacy_web_url as Setting records" do
    settings = Settings.new(legacy_db_uri: 'https://db.example', legacy_web_url: 'https://web.example')
    settings.save

    assert_equal 'https://db.example', Setting.find_by(key: 'legacy_db_uri').value
    assert_equal 'https://web.example', Setting.find_by(key: 'legacy_web_url').value
  end

  test "save updates existing Setting records instead of duplicating them" do
    Settings.new(legacy_db_uri: 'https://first.example').save
    Settings.new(legacy_db_uri: 'https://second.example').save

    assert_equal 1, Setting.where(key: 'legacy_db_uri').count
    assert_equal 'https://second.example', Setting.find_by(key: 'legacy_db_uri').value
  end
end
