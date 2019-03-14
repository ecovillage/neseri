# == Schema Information
#
# Table name: seminars
#
#  id                          :integer          not null, primary key
#  title                       :string
#  subtitle                    :string
#  description                 :text
#  attendees_minimum           :integer
#  attendees_maximum           :integer
#  attendees_preconditions     :string
#  please_bring                :string
#  start_date                  :datetime
#  end_date                    :datetime
#  cancellation_time           :integer          default(7)
#  cancellation_reason         :string
#  room_material               :string
#  room_extras                 :string
#  royalty_participant         :decimal(, )
#  royalty_participant_reduced :decimal(, )
#  material_cost               :decimal(, )
#  honorar                     :decimal(, )
#  kind                        :string           default("user")
#  uuid                        :string
#  locked                      :boolean          default(FALSE)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  creator_id                  :integer
#

class Seminar < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :title, presence: true

  validate :end_after_start
  validates :start_date, :end_date, presence: true

  private

  def end_after_start
    return if end_date.blank? || start_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, :must_be_before_start_date)
    end
  end
end
