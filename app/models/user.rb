class User < ApplicationRecord
  SIGN_UP_REQUIRE_ATTRIBUTES = %i(user_name email password
password_confirmation).freeze
  attr_accessor :remember_token

  has_many :addresses, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum role: {customer: 0, admin: 1}

  before_save :downcase_email

  validates :user_name, presence: true,
            length: {maximum: Settings.value.max_user_name}

  validates :email,
            presence: true,
            length: {maximum: Settings.value.max_user_email},
            format: {with: Settings.value.valid_email},
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length: {minimum: Settings.value.min_user_password},
            allow_nil: true

  has_secure_password

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
