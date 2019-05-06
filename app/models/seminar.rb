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
#  seminar_kind_id             :integer
#  accommodation               :string
#  user_seminar_id             :integer
#  alternative_dates           :text
#  other_extras                :text
#  room_wish_id_id             :integer
#

class Seminar < ApplicationRecord
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :seminar_kind, optional: true

  belongs_to :user_seminar, class_name: 'Seminar', optional: true, inverse_of: :admin_seminar, foreign_key: 'user_seminar_id'
  has_one :admin_seminar, class_name: 'Seminar', inverse_of: :user_seminar, foreign_key: 'user_seminar_id'

  belongs_to :wished_room, class_name: 'Room', optional: true, inverse_of: :seminars, foreign_key: 'wished_room_id'

  has_many :seminar_instructors, inverse_of: :seminar
  has_many :instructors, through: :seminar_instructors, class_name: "User", source: 'user'

  accepts_nested_attributes_for :seminar_instructors,
    reject_if: :all_blank, allow_destroy: true
  # validates_associated :seminar_instructors ?

  validates :title, presence: true

  validate :end_after_start
  validates :start_date, :end_date, presence: true

  scope :active, -> { where(active: true) }
  scope :future, -> { where("start_date >= ?", DateTime.now) }
  scope :past,   -> { where("start_date <= ?", DateTime.now) }
  scope :admin_copies, -> { where("user_seminar_id NOT NULL") }

  after_initialize do |record|
    record.start_date ||= DateTime.new(DateTime.now.year + 1, 1, 20, 20, 30)
    record.end_date   ||= (record.start_date + 2.days).change({hour: 13})
  end

  def is_user_seminar?
    !user_seminar_id?
  end

  def is_admin_seminar?
    user_seminar_id?
  end

  protected

  private

  def end_after_start
    return if end_date.blank? || start_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, :must_be_before_start_date)
    end
  end
end
