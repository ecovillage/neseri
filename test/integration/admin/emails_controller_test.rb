require 'test_helper'

class Admin::EmailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @mail = Ahoy::Message.create!(to: 'someone@example.com', subject: 'Hello', mailer: 'ApplicationMailer',
      content: 'Hi there', sent_at: Time.current)
  end

  test "an admin can list and show sent emails" do
    sign_in users(:admin)

    get admin_emails_path
    assert_response :success
    assert_select 'td', text: 'someone@example.com'

    get admin_email_path(@mail)
    assert_response :success
    assert_select 'pre', text: 'Hi there'
  end

  test "a regular user can not list or show sent emails" do
    sign_in users(:fulluser)

    get admin_emails_path
    assert_redirected_to root_path

    get admin_email_path(@mail)
    assert_redirected_to root_path
  end
end
