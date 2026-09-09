require 'test_helper'

class Seminars::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @seminar = seminars(:one)
    @seminar.update!(creator: users(:fulluser))
    @seminar.files.attach(
      io: File.open(Rails.root.join('test/fixtures/files/test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    @attachment = @seminar.files.last
  end

  test "the seminar's creator can delete an attachment" do
    sign_in users(:fulluser)

    delete seminar_attachment_path(seminar_id: @seminar.id, id: @attachment.id)

    assert_redirected_to @seminar
    follow_redirect!
    assert_select '.notification', text: 'Anhang gelöscht'

    refute ActiveStorage::Attachment.exists?(@attachment.id)
  end

  test "a user without access to the seminar can not delete its attachments" do
    sign_in users(:veteran)

    delete seminar_attachment_path(seminar_id: @seminar.id, id: @attachment.id)

    assert_redirected_to root_path
    follow_redirect!
    assert_select '.notification', text: 'Keine Berechtigung, diese Seite anzusehen!'

    assert ActiveStorage::Attachment.exists?(@attachment.id)
  end
end
