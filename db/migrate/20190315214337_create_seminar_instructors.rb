class CreateSeminarInstructors < ActiveRecord::Migration[5.2]
  def change
    create_table :seminar_instructors do |t|
      t.references :seminar, foreign_key: true
      t.references :instructor, foreign_key: true
      t.text :qualification
      t.boolean :main_contact
      t.string :accommodation

      t.timestamps
    end
  end
end
