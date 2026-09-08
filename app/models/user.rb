# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#  firstname              :string
#  lastname               :string
#  address                :string
#  fax                    :string
#  phone                  :string
#  mobile                 :string
#  homepage               :string
#  tos_accepted_at        :date
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :created_seminars, class_name: 'Seminar', foreign_key: 'creator_id'
  has_many :seminar_instructors, inverse_of: 'user'
  has_many :teaching_seminars, class_name: 'Seminar', foreign_key: 'seminar_id', inverse_of: 'instructors', source: 'seminar', through: :seminar_instructors

  belongs_to :instructor, required: false

  before_validation :downcase_strip_email
  before_validation :prepend_https_to_homepage

  validates_acceptance_of :tos_agreement, :allow_nil => false, on: :create

  # Only enforced on sign-up (on: :create); invited users are created via
  # User.invite!(validate: false) and fill in these fields later on the
  # instructor page, so this must not block invitation acceptance or later
  # profile updates for users who haven't completed them yet.
  validates_presence_of :firstname, :lastname, :phone, on: :create

  def downcase_strip_email
    self.email = self.email.downcase.strip
  end

  def prepend_https_to_homepage
    if self.homepage.present?
      self.homepage = homepage.strip
      if !self.homepage.start_with? "http"
        self.homepage = "https://#{self.homepage}"
      end
    end
  end

  after_create :set_tos_accepted_at

  def set_tos_accepted_at
    update(tos_accepted_at: DateTime.now)
  end

  def profile_missing?
    firstname.to_s == '' || lastname.to_s == '' || address.to_s == ''
  end

  # Deliver Devise notifications (confirmation, password reset, ...) via
  # ActiveJob instead of inline. A synchronous #deliver_now here means an
  # SMTP hiccup (wrong credentials, timeout, provider downtime) raises
  # inside the web request and turns an otherwise-successful signup/reset
  # into a 500, even though the record was already committed. deliver_later
  # decouples that: the request succeeds regardless, and mail delivery
  # failures are retried/logged as a background job failure instead.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
