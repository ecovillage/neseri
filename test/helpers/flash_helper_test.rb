require 'test_helper'

class FlashHelperTest < ActiveSupport::TestCase
  include FlashHelper

  setup { @flash = {} }

  def flash
    @flash
  end

  test "add_flash with a hash adds each value to a Set for that flash type" do
    add_flash notice: 'Hello', info: 'World'

    assert_equal Set['Hello'], flash[:notice]
    assert_equal Set['World'], flash[:info]
  end

  test "add_flash with a hash appends to an existing Set instead of replacing it" do
    add_flash notice: 'One'
    add_flash notice: 'Two'

    assert_equal Set['One', 'Two'], flash[:notice]
  end

  test "add_flash with key/value ignores a nil key or a nil value" do
    add_flash nil, 'value'
    add_flash :notice, nil

    assert_empty flash
  end

  test "add_flash with key/value adds the value" do
    add_flash :notice, 'Hello'

    assert_equal Set['Hello'], flash[:notice]
  end

  test "add_flashs adds each non-blank keyword flash, skipping blank ones" do
    add_flashs notice: 'N', warning: nil, success: 'S'

    assert_equal ['N'], flash[:notice]
    assert_equal ['S'], flash[:success]
    refute flash.key?(:warning)
  end

  test "add_flashs does not add a duplicate message to the same type" do
    add_flashs notice: 'N'
    add_flashs notice: 'N'

    assert_equal ['N'], flash[:notice]
  end

  test "add_flashs also accepts a plain hash of message_type => message" do
    add_flashs({ error: 'E' })

    assert_equal ['E'], flash[:error]
  end

  test "add_flashs via the hash form skips blank messages and duplicates" do
    add_flashs({ error: '' })
    refute flash.key?(:error)

    add_flashs({ error: 'E' })
    add_flashs({ error: 'E' })
    assert_equal ['E'], flash[:error]
  end
end
