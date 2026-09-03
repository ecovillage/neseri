# One-off data import: load the content of an external sqlite3 file into
# the local installation's own sqlite3 database (see
# ansible/playbooks/import-sqlite.yml for the equivalent against the
# production Postgres database, which uses pgloader instead since its
# target isn't sqlite3).
#
# This REPLACES data, it does not merge: every table found in both the
# source file and the local database - including `schema_migrations` and
# `ar_internal_metadata` - is deleted on the local side and reloaded from
# the source file's rows. That means the source file's migration history
# overwrites whatever `rails db:prepare` had recorded locally; if the two
# disagree on which migrations were applied, run `rails db:migrate`
# afterwards to bring the schema itself back in line with that history.
# Tables that only exist on one side are left untouched.
#
# A backup copy of the current local database is taken first, under
# db/backups/.
#
# Usage:
#   bin/rails "neseri:import_sqlite[/path/to/file.sqlite3]"
# or:
#   SQLITE_DB_PATH=/path/to/file.sqlite3 bin/rails neseri:import_sqlite
#
# Pass CONFIRM=yes to skip the interactive confirmation prompt.

namespace :neseri do
  desc "Import a sqlite3 file's content into the local database"
  task :import_sqlite, [:sqlite_db_path] => :environment do |_t, args|
    require "fileutils"

    sqlite_db_path = args[:sqlite_db_path] || ENV["SQLITE_DB_PATH"]

    if sqlite_db_path.to_s.empty?
      abort <<~MSG
        Pass the sqlite3 file to import:
          bin/rails "neseri:import_sqlite[/path/to/file.sqlite3]"
        or:
          SQLITE_DB_PATH=/path/to/file.sqlite3 bin/rails neseri:import_sqlite
      MSG
    end

    abort "No such file: #{sqlite_db_path}" unless File.file?(sqlite_db_path)

    connection = ActiveRecord::Base.connection

    unless connection.adapter_name.downcase.include?("sqlite")
      abort <<~MSG
        The '#{Rails.env}' database is not sqlite3 (adapter is #{connection.adapter_name}).
        This task only imports into a sqlite3-backed local database; for a
        Postgres target use ansible/playbooks/import-sqlite.yml instead.
      MSG
    end

    target_db_path = Rails.root.join(connection.pool.db_config.database)

    if File.expand_path(sqlite_db_path) == target_db_path.to_s
      abort "sqlite_db_path is the local database itself (#{target_db_path}) - nothing to import."
    end

    puts <<~MSG
      This REPLACES data in the local '#{Rails.env}' database
      (#{target_db_path}): every table also found in

        #{sqlite_db_path}

      - including schema_migrations/ar_internal_metadata - is deleted and
      reloaded from there. A backup is taken first.
    MSG

    unless ENV["CONFIRM"] == "yes"
      print "Type 'yes' to continue: "
      $stdout.flush
      abort "Aborted - confirmation not given." unless $stdin.gets.to_s.strip == "yes"
    end

    FileUtils.mkdir_p(target_db_path.dirname.join("backups"))
    backup_path = target_db_path.dirname.join("backups", "pre-import-#{Time.now.utc.strftime('%Y%m%d%H%M%S')}.sqlite3")

    connection.execute("PRAGMA wal_checkpoint(FULL)")
    FileUtils.cp(target_db_path, backup_path)
    puts "Backed up current database to #{backup_path}"

    connection.execute("PRAGMA foreign_keys = OFF")
    connection.execute("ATTACH DATABASE #{connection.quote(sqlite_db_path)} AS import_src")

    begin
      source_tables = connection.select_values("SELECT name FROM import_src.sqlite_master WHERE type = 'table'")
      target_tables = connection.select_values("SELECT name FROM sqlite_master WHERE type = 'table'")

      tables_to_load = source_tables & target_tables
      skipped        = source_tables - target_tables
      puts "Skipping tables not present in the local schema: #{skipped.join(', ')}" unless skipped.empty?

      connection.transaction do
        tables_to_load.each do |table|
          quoted_table = connection.quote_table_name(table)
          connection.execute("DELETE FROM #{quoted_table}")
          connection.execute("INSERT INTO #{quoted_table} SELECT * FROM import_src.#{quoted_table}")
          puts "Loaded #{table}"
        end
      end
    ensure
      connection.execute("DETACH DATABASE import_src")
      connection.execute("PRAGMA foreign_keys = ON")
    end

    puts "Done. Run `rails db:migrate` afterwards if the imported migration history disagrees with the local schema."
  end
end
