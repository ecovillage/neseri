class AddAlternativeDatesAndRoomWishToSeminar < ActiveRecord::Migration[5.2]
  def change
    add_column :seminars, :alternative_dates, :text
    add_column :seminars, :other_extras, :text
    add_reference :seminars, :room_wish, foreign_key: { to_table: :rooms }, index: true
  end
end
