require 'test_helper'

class Admin::AdminSeminars::UserMappingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can map a user to a legacy uuid, creating the mapping" do
    sign_in users(:admin)
    refute Publication::UserMapping.exists?(user: users(:veteran))

    post admin_user_user_mapping_path(user_id: users(:veteran).id), params: { uuid: 'legacy-uuid-1' }

    assert_redirected_to admin_admin_seminars_path
    mapping = Publication::UserMapping.find_by(user: users(:veteran))
    assert_equal 'legacy-uuid-1', mapping.uuid
  end

  test "posting again for the same user updates the existing mapping instead of duplicating it" do
    sign_in users(:admin)
    # bob already has a mapping via fixtures (bob_map)
    post admin_user_user_mapping_path(user_id: users(:bob).id), params: { uuid: 'new-uuid' }

    assert_equal 1, Publication::UserMapping.where(user: users(:bob)).count
    assert_equal 'new-uuid', Publication::UserMapping.find_by(user: users(:bob)).uuid
  end

  test "a regular user can not create a user mapping" do
    sign_in users(:fulluser)

    post admin_user_user_mapping_path(user_id: users(:veteran).id), params: { uuid: 'legacy-uuid-1' }

    assert_redirected_to root_path
    refute Publication::UserMapping.exists?(user: users(:veteran))
  end
end
