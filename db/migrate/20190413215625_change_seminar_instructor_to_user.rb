class ChangeSeminarInstructorToUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :seminar_instructors, :instructor_id, :user_id
    remove_column :users, :instructor_id
  end
end
