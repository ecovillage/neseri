class AddTosAcceptedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tos_accepted_at, :date
  end
end
