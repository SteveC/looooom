class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]

  has_many :tickets, dependent: :destroy
  has_many :feature_usages, dependent: :destroy
  has_one :subscription, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.email = auth.info.email
      user.name = auth.info.name.presence || auth.info.nickname
      user.password = Devise.friendly_token[0, 32] if user.encrypted_password.blank?
      user.save!
    end
  end
end
