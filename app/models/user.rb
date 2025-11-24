class User < ApplicationRecord
  # --- 1. Authentication ---
  # This line is the magic. It requires the 'bcrypt' gem.
  # It automatically adds methods to set and authenticate a password.
  # It hashes the password and stores it in the 'password_digest' column.
  # [Image of has_secure_password logic flow diagram]
  has_secure_password

  # --- 2. Email Verification ---
  # This tells Rails to auto-generate a token for the
  # 'tamu_verification_token' column.
  has_secure_token :tamu_verification_token

  # This enables @user.resume.attach(params[:resume])
  has_one_attached :resume

  # --- 3. Table Relationships ---
  # A user (as a poster) can have many posts.
  # If a user is deleted, all their posts are also deleted.
  has_many :referral_posts, dependent: :destroy

  # A user (as a requester) can have many requests.
  # If a user is deleted, all their requests are also deleted.
  has_many :referral_requests, dependent: :destroy

  # A user can have many company verification records.
  # If a user is deleted, all their verifications are also deleted.
  has_many :company_verifications, dependent: :destroy

  # --- 4. Validations ---
  # Ensures the email is present, unique, and ends with @tamu.edu
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: /\A(.+)@tamu\.edu\z/i, message: "must be a valid @tamu.edu email" }

  # Password validation for security
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, if: :password_required?

  # These are optional but good to have.
  validates :first_name, presence: true, allow_blank: true
  validates :last_name, presence: true, allow_blank: true

  # --- 5. Helper Methods ---
  # A simple method to get the user's full name, e.g., "Khussal Pradh"
  def full_name
    "#{first_name} #{last_name}"
  end

  def password_required?
    # Require password if it's a new record OR if password field is not blank
    new_record? || !password.blank?
  end

  validate :resume_must_be_pdf_and_within_size

  def resume_must_be_pdf_and_within_size
    return unless resume.attached?

    unless resume.content_type == "application/pdf"
      resume.purge
      errors.add(:resume, "must be a PDF")
      return
    end

    if resume.byte_size > 5.megabytes
      resume.purge
      errors.add(:resume, "size must be less than 5 MB")
    end
  end
end
