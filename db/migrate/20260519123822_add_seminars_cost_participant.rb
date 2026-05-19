class AddSeminarsCostParticipant < ActiveRecord::Migration[8.1]
  COLUMN_NAMES = [
    :cost_participant,
    :cost_participant_reduced
  ]

  def up
    COLUMN_NAMES.each do |column_name|
      add_column :seminars, column_name, :decimal, precision: 8, scale: 2
    end

    calculate_values!
  end

  def down
    COLUMN_NAMES.each do |column_name|
      remove_column :seminars, column_name
    end
  end

  private

  def calculate_values!
    Seminar.all.each do |seminar|
      seminar.cost_participant = 
        seminar.royalty_participant.to_f/0.67
      seminar.cost_participant_reduced = 
        seminar.royalty_participant_reduced.to_f/0.67
      seminar.save!
    end
  end
end
