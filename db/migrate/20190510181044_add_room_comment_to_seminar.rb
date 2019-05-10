class AddRoomCommentToSeminar < ActiveRecord::Migration[5.2]
  def change
    add_column :seminars, :room_comment, :text
  end
end
