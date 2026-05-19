class LinksOfMediaCoverage < ActiveRecord::Migration[8.1]
  def change
    add_column :seminars, :media_coverage_links, :text
  end
end
