# frozen_string_literal: true

# `users` and `seminar_instructors` are the only two tables whose primary key
# was declared as plain `id: :integer` (schema.rb: `id: :integer, default:
# nil`) instead of Rails' normal (implicit) primary key. That column has no
# default: it doesn't auto-increment, so every INSERT that doesn't supply an
# id explicitly (i.e. every normal ActiveRecord #create, including a new user
# self-registering) fails with a NOT NULL violation. That's the 500 on the
# registration form in production.
#
# schema.rb has since been re-dumped from Postgres (`id: :serial`, which
# *does* get a real sequence-backed default), so a fresh `db:schema:load`
# creates the columns correctly from here on - this migration exists only to
# patch the already-provisioned production database, which still has the
# broken (defaultless) columns from before that schema.rb fix.
class AddMissingPgIdSequenceToUsersAndSeminarInstructors < ActiveRecord::Migration[8.1]
  def up
    add_serial_default(:users)
    add_serial_default(:seminar_instructors)
  end

  def down
    %i[users seminar_instructors].each do |table|
      execute "ALTER TABLE #{quoted_table_name(table)} ALTER COLUMN id DROP DEFAULT"
      execute "DROP SEQUENCE IF EXISTS #{table}_id_seq"
    end
  end

  private

  # Recreates the "serial" pattern Rails normally sets up for a primary key:
  # a sequence owned by the column, its next value seeded past the current
  # max id (so it can't collide with existing rows), set as the column's
  # default.
  def add_serial_default(table)
    seq = "#{table}_id_seq"
    quoted_table = quoted_table_name(table)

    execute "CREATE SEQUENCE IF NOT EXISTS #{seq} OWNED BY #{quoted_table}.id"
    execute <<~SQL.squish
      SELECT setval('#{seq}', COALESCE((SELECT MAX(id) FROM #{quoted_table}), 0) + 1, false)
    SQL
    execute "ALTER TABLE #{quoted_table} ALTER COLUMN id SET DEFAULT nextval('#{seq}')"
  end

  def quoted_table_name(table)
    connection.quote_table_name(table)
  end
end
