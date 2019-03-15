class AddAccommodationToSeminar < ActiveRecord::Migration[5.2]
  def change
    add_column :seminars, :accommodation, :string
  end
end
