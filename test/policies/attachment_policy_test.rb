require 'test_helper'

class AttachmentPolicyTest < ActiveSupport::TestCase
  setup do
    @seminar = seminars(:bob_and_janes_seminar)
    @seminar.files.attach(
      io: File.open(Rails.root.join('test/fixtures/files/test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    @attachment = @seminar.files.last
  end

  test "an admin can always destroy an attachment" do
    assert AttachmentPolicy.new(@attachment, user: users(:admin)).apply(:destroy?)
  end

  test "a user with access to the seminar can destroy an attachment" do
    assert AttachmentPolicy.new(@attachment, user: users(:bob)).apply(:destroy?)
  end

  test "a user without access to the seminar can not destroy an attachment" do
    refute AttachmentPolicy.new(@attachment, user: users(:veteran)).apply(:destroy?)
  end

  test "nobody, not even an admin, can destroy an attachment on a locked seminar" do
    @seminar.update!(locked: true)
    refute AttachmentPolicy.new(@attachment, user: users(:admin)).apply(:destroy?)
    refute AttachmentPolicy.new(@attachment, user: users(:bob)).apply(:destroy?)
  end
end
