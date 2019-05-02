class AddActiveToSeminars < ActiveRecord::Migration[5.2]
  def change
    add_column :seminars, :active, :boolean, default: true
  end
end
