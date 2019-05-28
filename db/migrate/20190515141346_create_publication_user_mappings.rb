class CreatePublicationUserMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :publication_user_mappings do |t|
      t.references :user, foreign_key: true
      t.string :uuid

      t.timestamps
    end
  end
end
