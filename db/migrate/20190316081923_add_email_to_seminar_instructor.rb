class AddEmailToSeminarInstructor < ActiveRecord::Migration[5.2]
  def change
    add_column :seminar_instructors, :email, :string
    add_column :seminar_instructors, :comment, :string

    add_index :seminar_instructors, :email
  end
end
