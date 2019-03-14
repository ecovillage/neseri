class AddKindToSeminar < ActiveRecord::Migration[5.2]
  def change
    add_reference :seminars, :seminar_kind, foreign_key: true
  end
end
