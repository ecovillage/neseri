# frozen_string_literal: true

# `users` and `seminar_instructors` are the only two tables whose primary key
# was declared as plain `id: :integer` instead of Rails' normal (implicit)
# primary key. On sqlite3 (dev/test) that's harmless - an INTEGER PRIMARY KEY
# column auto-increments via the rowid regardless of an explicit DEFAULT, so
# schema.rb (dumped from the sqlite3 dev db) faithfully but misleadingly
# records `default: nil` for it. On PostgreSQL (production), a plain integer
# column with no default does NOT auto-increment: every INSERT that doesn't
# supply an id explicitly (i.e. every normal ActiveRecord #create, including
# a new user self-registering) fails with a NOT NULL violation. That's the
# 500 on the registration form in production.
#
# This can't be fixed in schema.rb: there is no syntax that means "have a
# sequence-backed default on Postgres, but nothing special on sqlite3", so a
# fresh `db:schema:load` against Postgres would still recreate the same
# broken columns - this migration only patches an already-provisioned
# Postgres database (i.e. it fixes production going forward, but a
# from-scratch environment created via schema:load would still need it
# re-applied by hand).
class AddMissingPgIdSequenceToUsersAndSeminarInstructors < ActiveRecord::Migration[8.1]
  def up
    return unless postgresql?

    add_serial_default(:users)
    add_serial_default(:seminar_instructors)
  end

  def down
    return unless postgresql?

    %i[users seminar_instructors].each do |table|
      execute "ALTER TABLE #{quoted_table_name(table)} ALTER COLUMN id DROP DEFAULT"
      execute "DROP SEQUENCE IF EXISTS #{table}_id_seq"
    end
  end

  private

  def postgresql?
    connection.adapter_name == "PostgreSQL"
  end

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
