class CreateSeminarKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :seminar_kinds do |t|
      t.string :name
      t.boolean :active, default: true
      t.text :description

      t.timestamps
    end
  end
end
