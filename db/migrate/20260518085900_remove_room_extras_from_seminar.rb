class RemoveRoomExtrasFromSeminar < ActiveRecord::Migration[8.1]
  def up
    return unless Seminar.has_attribute?(:room_extras)

    Seminar.where.not(room_extras: "").each do |seminar|
      seminar.room_material =
        [seminar.room_material, seminar.room_extras].reject(&:blank?).join(", ")
      seminar.room_extras = ""
      seminar.save
    end

    remove_column :seminars, :room_extras
  end

  def down
  end
end
