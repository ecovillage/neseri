class RemoveHonorarFromSeminar < ActiveRecord::Migration[5.2]
  def change
    remove_column :seminars, :honorar
  end
end
