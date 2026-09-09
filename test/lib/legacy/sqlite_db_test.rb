require 'test_helper'
require 'legacy/sqlite_db'

class Legacy::SQLiteDBTest < ActiveSupport::TestCase
  test "instructor_hash maps a legacy sqlite row's positional columns" do
    row = ['old-1', 'Jane', 'Doe', 'Some address', 'jane@example.com',
           '123', '456', '789', 'https://jane.example', 't']

    hash = Legacy::SQLiteDB.instructor_hash(row)

    assert_equal({
      old_id: 'old-1', firstname: 'Jane', lastname: 'Doe', address: 'Some address',
      email: 'jane@example.com', fax: '123', phone: '456', mobile: '789',
      homepage: 'https://jane.example', main: 't',
    }, hash)
  end

  test "seminar_hash maps a legacy sqlite row's positional columns" do
    row = (1..33).to_a

    hash = Legacy::SQLiteDB.seminar_hash(row)

    assert_equal 1, hash[:old_id]
    assert_equal 2, hash[:title]
    assert_equal 33, hash[:subtitle]
    assert_equal 33, hash.size
  end
end
