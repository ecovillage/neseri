class AddInstructorToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :instructor, foreign_key: true
  end
end
