class AddKindToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :kind, :text
    add_index :rooms, :kind
    add_column :rooms, :active, :boolean, default: true
  end
end
