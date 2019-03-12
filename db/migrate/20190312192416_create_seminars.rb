class CreateSeminars < ActiveRecord::Migration[5.2]
  def change
    create_table :seminars do |t|
      t.string :title
      t.string :subtitle
      t.text :description
      t.integer :attendees_minimum
      t.integer :attendees_maximum
      t.string :attendees_preconditions
      t.string :please_bring
      t.datetime :start_date
      t.datetime :end_date
      t.integer :cancellation_time, default: 7
      t.string :cancellation_reason
      t.string :room_material
      t.string :room_extras
      t.decimal :royalty_participant
      t.decimal :royalty_participant_reduced
      t.decimal :material_cost
      t.decimal :honorar
      t.string :kind, default: :user
      t.string :uuid
      t.boolean :locked, default: false

      t.timestamps
    end
  end
end
