require 'test_helper'
require 'minitest/mock'

class Admin::AdminSeminars::PublicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Has no seminar_instructors of its own in fixtures, so
    # all_instructors_legacy_mapped? is vacuously true and the legacy
    # instructor lookup loop simply does nothing - a clean base case each
    # test can add its own seminar_instructor to when it needs one.
    @admin_seminar = seminars(:admin_copy_bob_and_janes_seminar)
  end

  def add_mapped_instructor
    user = User.create!(email: 'referee@example.com', password: 'password123', password_confirmation: 'password123',
      firstname: 'Ref', lastname: 'Eree', phone: '12345', tos_agreement: true)
    instructor = SeminarInstructor.create!(seminar: @admin_seminar, email: user.email,
      firstname: 'Ref', lastname: 'Eree', address: 'Refstreet 1', phone: '12345')
    Publication::UserMapping.create!(user: user, uuid: 'legacy-person-uuid')
    instructor
  end

  # --- show ---

  test "show redirects to new while the admin seminar is not yet published" do
    sign_in users(:admin)

    get admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to new_admin_admin_seminar_publication_path(@admin_seminar)
  end

  test "show renders the seminar once it's published" do
    @admin_seminar.update!(uuid: 'legacy-seminar-uuid')
    sign_in users(:admin)

    get admin_admin_seminar_publication_path(@admin_seminar)
    assert_response :success
    assert_match @admin_seminar.title, response.body
  end

  test "show is admin-only" do
    sign_in users(:fulluser)

    get admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to root_path
  end

  # --- new ---

  test "new warns and redirects for a plain user seminar" do
    sign_in users(:admin)

    get new_admin_admin_seminar_publication_path(seminars(:one))
    assert_redirected_to admin_admin_seminars_path
  end

  test "new warns and redirects once the admin seminar is already published" do
    @admin_seminar.update!(uuid: 'legacy-seminar-uuid')
    sign_in users(:admin)

    get new_admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to admin_admin_seminars_path
  end

  test "new allows publishing once every instructor is (or none need to be) legacy-mapped" do
    sign_in users(:admin)

    get new_admin_admin_seminar_publication_path(@admin_seminar)
    assert_response :success
    assert_select "a[href='#{admin_admin_seminar_publication_path(@admin_seminar)}']"
  end

  test "new lists legacy matches for an unmapped instructor, and does not allow publishing yet" do
    user = User.create!(email: 'unmapped@example.com', password: 'password123', password_confirmation: 'password123',
      firstname: 'Un', lastname: 'Mapped', phone: '12345', tos_agreement: true)
    SeminarInstructor.create!(seminar: @admin_seminar, email: user.email,
      firstname: 'Un', lastname: 'Mapped', address: 'Street 1', phone: '12345')

    legacy_match = { id: 'legacy-doc-1', firstname: 'Un', lastname: 'Mapped', email: user.email,
      link: 'https://legacy.example/edit/legacy-doc-1' }

    sign_in users(:admin)
    Legacy::Instructors.stub(:get_for, ->(_instructor, _uri) { [legacy_match] }) do
      get new_admin_admin_seminar_publication_path(@admin_seminar)
    end

    assert_response :success
    assert_match 'Un Mapped', response.body
    assert_select "a[href='#{admin_admin_seminar_publication_path(@admin_seminar)}']", count: 0
  end

  test "new shows an error and still renders when the legacy system is unreachable" do
    add_mapped_instructor

    sign_in users(:admin)
    Legacy::Instructors.stub(:get_for, ->(_instructor, _uri) { raise Errno::ECONNREFUSED }) do
      get new_admin_admin_seminar_publication_path(@admin_seminar)
    end

    assert_response :success
    assert_select '.notification', text: 'Konnte nicht mit Alt-System verbinden!'
  end

  test "new is admin-only" do
    sign_in users(:fulluser)

    get new_admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to root_path
  end

  # --- update (creates a legacy person for one instructor) ---

  test "update pushes the instructor to the legacy system and stores the resulting mapping" do
    user = User.create!(email: 'newref@example.com', password: 'password123', password_confirmation: 'password123',
      firstname: 'New', lastname: 'Ref', phone: '12345', tos_agreement: true)
    instructor = SeminarInstructor.create!(seminar: @admin_seminar, email: user.email,
      firstname: 'New', lastname: 'Ref', address: 'Street 1', phone: '12345')

    fake_export = Object.new
    def fake_export.push_to_legacy(instructor, legacy_db_uri)
      'new-legacy-uuid'
    end

    sign_in users(:admin)
    Legacy::PersonExport.stub(:new, fake_export) do
      put admin_admin_seminar_publication_path(@admin_seminar), params: { instructor_id: instructor.id }
    end

    assert_redirected_to admin_admin_seminar_publication_path(@admin_seminar)
    assert_equal 'new-legacy-uuid', Publication::UserMapping.find_by(user: user).uuid
  end

  test "update is admin-only" do
    instructor = add_mapped_instructor
    sign_in users(:fulluser)

    put admin_admin_seminar_publication_path(@admin_seminar), params: { instructor_id: instructor.id }
    assert_redirected_to root_path
  end

  # --- create (the actual publish) ---

  test "create warns and redirects for a plain user seminar" do
    sign_in users(:admin)

    post admin_admin_seminar_publication_path(seminars(:one))
    assert_redirected_to admin_admin_seminars_path
  end

  test "create warns and redirects once the admin seminar is already published" do
    @admin_seminar.update!(uuid: 'legacy-seminar-uuid')
    sign_in users(:admin)

    post admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to admin_admin_seminars_path
  end

  test "create redirects to new when an instructor still needs legacy-mapping" do
    user = User.create!(email: 'stillunmapped@example.com', password: 'password123', password_confirmation: 'password123',
      firstname: 'Still', lastname: 'Unmapped', phone: '12345', tos_agreement: true)
    SeminarInstructor.create!(seminar: @admin_seminar, email: user.email,
      firstname: 'Still', lastname: 'Unmapped', address: 'Street 1', phone: '12345')

    sign_in users(:admin)
    post admin_admin_seminar_publication_path(@admin_seminar)

    assert_redirected_to new_admin_admin_seminar_publication_path
    refute @admin_seminar.reload.uuid
  end

  test "create publishes the seminar, setting the uuid on both the admin and the user seminar" do
    add_mapped_instructor

    fake_export = Object.new
    def fake_export.push(legacy_db_uri) = []
    def fake_export.seminar_uuid = 'published-uuid'

    sign_in users(:admin)
    Legacy::Export.stub(:new, fake_export) do
      post admin_admin_seminar_publication_path(@admin_seminar)
    end

    assert_redirected_to admin_admin_seminars_path
    assert_equal 'published-uuid', @admin_seminar.reload.uuid
    assert_equal 'published-uuid', @admin_seminar.user_seminar.reload.uuid
  end

  test "create shows a failure notice and does not set the uuid when the legacy push fails" do
    add_mapped_instructor

    fake_export = Object.new
    def fake_export.push(legacy_db_uri) = [:failure]

    sign_in users(:admin)
    Legacy::Export.stub(:new, fake_export) do
      post admin_admin_seminar_publication_path(@admin_seminar)
    end

    assert_redirected_to admin_admin_seminars_path
    refute @admin_seminar.reload.uuid
  end

  test "create is admin-only" do
    sign_in users(:fulluser)

    post admin_admin_seminar_publication_path(@admin_seminar)
    assert_redirected_to root_path
  end
end
