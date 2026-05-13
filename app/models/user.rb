class User < ApplicationRecord
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

  before_validation :set_slug

  validates :slug, presence: true, uniqueness: true

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

  def to_param
    slug.presence || id.to_s
  end

  private

  def set_slug
    return if slug.present?

    self.slug = unique_slug
  end

  def unique_slug
    base = name.presence || email.to_s.split("@").first.presence || "user"
    candidate = base.parameterize.presence || "user"
    suffix = 2

    while self.class.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base.parameterize}-#{suffix}"
      suffix += 1
    end

    candidate
  end
end
