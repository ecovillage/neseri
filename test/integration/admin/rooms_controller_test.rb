require 'test_helper'

class Admin::RoomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "an admin can list, create, deactivate and reactivate rooms" do
    sign_in users(:admin)

    get admin_rooms_path
    assert_response :success
    assert_select 'td', text: rooms(:big_room).name

    get new_admin_room_path
    assert_response :success

    assert_difference 'Room.count', 1 do
      post admin_rooms_path, params: { room: { name: 'New Room' } }
    end
    assert_redirected_to admin_rooms_path
    room = Room.find_by(name: 'New Room')
    assert room.active
    assert_equal 'event', room.kind

    patch admin_room_path(room)
    assert_redirected_to admin_rooms_path
    refute room.reload.active

    delete admin_room_path(rooms(:big_room))
    assert_redirected_to admin_rooms_path
    refute rooms(:big_room).reload.active
  end

  test "creating a room with a name that is already taken re-renders the form" do
    sign_in users(:admin)

    assert_no_difference 'Room.count' do
      post admin_rooms_path, params: { room: { name: rooms(:big_room).name } }
    end
    assert_response :success
  end

  test "a regular user can not manage rooms" do
    sign_in users(:fulluser)

    get admin_rooms_path
    assert_redirected_to root_path

    get new_admin_room_path
    assert_redirected_to root_path

    post admin_rooms_path, params: { room: { name: 'Nope' } }
    assert_redirected_to root_path
    refute Room.exists?(name: 'Nope')
  end
end
