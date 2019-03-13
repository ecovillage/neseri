class AddCreatorToSeminar < ActiveRecord::Migration[5.2]
  def change
    add_reference :seminars, :creator, foreign_key: { to_table: :users }, index: true
  end
end
