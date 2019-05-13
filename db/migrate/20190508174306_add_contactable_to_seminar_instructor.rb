class AddContactableToSeminarInstructor < ActiveRecord::Migration[5.2]
  def change
    add_column :seminar_instructors, :contactable, :boolean, default: false
  end
end
