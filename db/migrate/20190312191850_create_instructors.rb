class CreateInstructors < ActiveRecord::Migration[5.2]
  def change
    create_table :instructors do |t|
      t.string :firstname
      t.string :lastname
      t.string :address
      t.string :email
      t.string :fax
      t.string :phone
      t.string :mobile
      t.string :homepage

      t.timestamps
    end
  end
end
