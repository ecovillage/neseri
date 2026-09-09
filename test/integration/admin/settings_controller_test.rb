require 'test_helper'

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can view and update the legacy settings" do
    sign_in users(:admin)

    get admin_settings_path
    assert_response :success

    patch admin_setting_path(1), params: { settings: { legacy_db_uri: 'https://db.example', legacy_web_url: 'https://web.example' } }

    assert_response :success
    assert_equal 'https://db.example', Setting.find_by(key: 'legacy_db_uri').value
    assert_equal 'https://web.example', Setting.find_by(key: 'legacy_web_url').value
  end

  test "a regular user can not view or update the settings" do
    sign_in users(:fulluser)

    get admin_settings_path
    assert_redirected_to root_path

    patch admin_setting_path(1), params: { settings: { legacy_db_uri: 'https://evil.example' } }
    assert_redirected_to root_path
    refute Setting.exists?(key: 'legacy_db_uri', value: 'https://evil.example')
  end
end
