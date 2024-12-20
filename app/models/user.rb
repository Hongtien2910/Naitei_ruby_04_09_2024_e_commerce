class User < ApplicationRecord
  SIGN_UP_REQUIRE_ATTRIBUTES = %i(user_name email password
password_confirmation avatar).freeze
  RESET_PARAMS = %i(password password_confirmation).freeze
  USER_ADMIN_ATTRIBUTES = %i(user_name email role activated).freeze

  has_one_attached :avatar do |attachable|
    attachable.variant :display, resize_to_limit: [Settings.ui.avatar_size,
                            Settings.ui.avatar_size]
  end
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :notifications, dependent: :destroy

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

  scope :by_activation_status, lambda {|status|
    where(activated: status) if status.present?
  }

  scope :by_role, lambda {|role|
    where(role:) if role.present?
  }

  scope :sorted, lambda {|column, direction|
    order("#{column} #{direction}") if column.present?
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  %i(password_reset order_confirm order_cancel
order_update).each do |email_type|
    define_method "send_#{email_type}_email" do |*args|
      UserMailer.send(email_type, self, *args).deliver_now
    end
  end
  class << self
    def ransackable_attributes _auth_object = nil
      %w(email user_name)
    end

    def ransackable_scopes _auth_object = nil
      [:by_activation_status, :by_role, :sorted]
    end

    def ransackable_associations _auth_object = nil
      %w(addresses orders reviews)
    end

    def top_user
      joins(:orders)
        .group("users.id")
        .order("COUNT(orders.id) DESC")
        .first
    end
  end
  def from_google user
    user_name = user[:name].presence || user[:email]

    create_with(
      uid: user[:uid],
      provider: "google",
      password: Devise.friendly_token[0, 20],
      user_name:
    ).find_or_create_by!(email: user[:email])
  end

  private
  def downcase_email
    email.downcase!
  end
end
