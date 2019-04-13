class AddInstructorFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :address, :string
    add_column :users, :fax, :string
    add_column :users, :phone, :string
    add_column :users, :mobile, :string
    add_column :users, :homepage, :string
  end
end
