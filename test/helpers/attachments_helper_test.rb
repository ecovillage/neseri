require 'test_helper'

class AttachmentsHelperTest < ActionView::TestCase
  setup do
    seminar = seminars(:one)
    seminar.files.attach(
      io: File.open(Rails.root.join('test/fixtures/files/test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    @file = seminar.files.last
  end

  test "renders the processed variant when the file is present" do
    html = attachment_thumbnail(@file)

    assert_match '<img', html
    refute_match 'fa-warning', html
  end

  test "renders a placeholder icon instead of raising when the file is missing on disk" do
    # Simulates exactly what broke in production: a database (row in
    # active_storage_blobs) that references a file no longer present on
    # disk, e.g. after restoring a DB dump without its Active Storage files.
    ActiveStorage::Blob.service.delete(@file.blob.key)

    html = attachment_thumbnail(@file)

    assert_match 'fa-warning', html
    refute_match '<img', html
  end
end
