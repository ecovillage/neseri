class RemoveEmailFromInstructor < ActiveRecord::Migration[5.2]
  def change
    remove_column :instructors, :email, :string
  end
end
