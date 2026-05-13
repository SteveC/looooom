class User < ApplicationRecord
  USERNAME_ADJECTIVES = %w[
    brave bright calm clever heavy quick steady warm
  ].freeze
  USERNAME_NOUNS = %w[
    banana harbor lantern meadow rocket summit compass river
  ].freeze
  KARMA_WEIGHTS = {
    ticket: 3,
    accepted_ticket: 12,
    shipped_ticket: 20,
    vote_cast: 1,
    vote_received: 1,
    comment: 2
  }.freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :trackable
  devise :database_authenticatable,
         :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :voted_tickets, through: :votes, source: :ticket
  has_many :ticket_comments, dependent: :destroy
  has_many :feature_usages, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :subscription, dependent: :destroy

  before_validation :normalize_username
  before_validation :set_slug
  before_update :mark_username_changed, if: :will_save_change_to_slug?

  validates :slug,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { in: 3..32 },
            format: {
              with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/,
              message: "can only contain letters, numbers, and hyphens"
            }
  validate :username_can_only_change_once, if: :will_save_change_to_slug?

  scope :configured_admin, lambda {
    admin_email = ENV["ADMIN_EMAIL"].to_s.downcase

    admin_email.present? ? where("LOWER(email) = ?", admin_email) : none
  }

  def self.from_omniauth(auth)
    email = auth.info.email.to_s.downcase
    user = find_by(provider: auth.provider, uid: auth.uid) || find_or_initialize_by(email: email)

    user.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = email
      user.name = auth.info.name.presence || auth.info.nickname
      user.password = Devise.friendly_token[0, 32] if user.encrypted_password.blank?
      user.admin = true if admin_email?(user.email)
      user.save!
    end
  end

  def self.admin_email?(email)
    ENV["ADMIN_EMAIL"].present? && email.to_s.casecmp?(ENV.fetch("ADMIN_EMAIL"))
  end

  def admin?
    self[:admin] || configured_admin?
  end

  def configured_admin?
    self.class.admin_email?(email)
  end

  def username
    slug
  end

  def username=(value)
    self.slug = value
  end

  def display_username
    username.tr("-", " ")
  end

  def username_change_available?
    username_changed_at.blank?
  end

  def karma_score
    karma_breakdown.values.sum
  end

  def karma_breakdown
    user_tickets = tickets

    {
      tickets: user_tickets.count * KARMA_WEIGHTS.fetch(:ticket),
      accepted_tickets: user_tickets.accepted.count * KARMA_WEIGHTS.fetch(:accepted_ticket),
      shipped_tickets: user_tickets.closedish.count * KARMA_WEIGHTS.fetch(:shipped_ticket),
      votes_cast: votes.count * KARMA_WEIGHTS.fetch(:vote_cast),
      votes_received: user_tickets.sum(:votes_count) * KARMA_WEIGHTS.fetch(:vote_received),
      comments: ticket_comments.visible.count * KARMA_WEIGHTS.fetch(:comment)
    }
  end

  def to_param
    slug.presence || id.to_s
  end

  private

  def normalize_username
    self.slug = slug.to_s.parameterize if slug.present?
  end

  def set_slug
    return if slug.present?
    return if persisted?

    self.slug = unique_generated_username
  end

  def unique_generated_username
    loop do
      candidate = [
        USERNAME_ADJECTIVES.sample,
        USERNAME_NOUNS.sample,
        rand(10..99)
      ].join("-")

      return candidate unless self.class.where.not(id: id).exists?(slug: candidate)
    end
  end

  def username_can_only_change_once
    return if new_record?
    return if username_change_available?

    errors.add(:username, "can only be changed once")
  end

  def mark_username_changed
    self.username_changed_at ||= Time.current
  end
end
