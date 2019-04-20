class LinkSeminars < ActiveRecord::Migration[5.2]
  def change
    add_reference :seminars, :user_seminar, foreign_key: { to_table: :seminars }, index: true
    #add_reference :seminars, :admin_seminar, foreign_key: { to_table: :seminars }, index: true
    #

    ## http://joshfrankel.me/blog/custom-named-belongs_to-associations-in-rails-with-foreign-key-constraints/
    ## Notice how the index is for :creator but references users
    #add_reference :journals, :creator, references: :users, index: true

    ## Just like the belongs_to contained class_name: :User, the foreign key
    ## also needs a specific custom column name as :creator_id
    #add_foreign_key :journals, :users, column: :creator_id
  end
end
