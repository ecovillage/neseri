class RemoveSaraswatiLegacyPublishingSupport < ActiveRecord::Migration[8.1]
  def change
    remove_column :seminars, :uuid, :string

    drop_table :publication_user_mappings do |t|
      t.references :user, foreign_key: true
      t.string :uuid

      t.timestamps
    end

    drop_table :settings do |t|
      t.string :key, index: { unique: true }
      t.string :value

      t.timestamps
    end
  end
end
