class AddAddressFieldsToInstructor < ActiveRecord::Migration[6.0]
  def change
    add_column :seminar_instructors, :firstname, :string
    add_column :seminar_instructors, :lastname, :string
    add_column :seminar_instructors, :address, :string
    add_column :seminar_instructors, :fax, :string
    add_column :seminar_instructors, :phone, :string
    add_column :seminar_instructors, :mobile, :string
    add_column :seminar_instructors, :homepage, :string
  end
end
