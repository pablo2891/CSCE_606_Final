class ReferralPost < ApplicationRecord
  # --- 1. Table Relationships ---
  # This model connects a User (the poster) and their Verification (the proof)
  belongs_to :user
  belongs_to :company_verification

  # If a post is deleted, all requests for it are also deleted.
  has_many :referral_requests, dependent: :destroy

  # --- 2. Enums (for the 'status' integer column) ---
  # This is the "Rails Way" to handle your status.
  # It maps the integer 0 to :active, 1 to :paused, etc.
  # It also gives you free helper methods like `post.active?` or `post.paused!`
  enum :status, { active: 0, paused: 1, closed: 2 }

  # --- 3. Validations ---
  validates :title, presence: true
  validates :company_name, presence: true
  validates :job_title, presence: true
  validates :questions, length: { maximum: 10 }, allow_blank: true

  # --- 4. Scopes (for easy searching) ---
  # This lets you write `ReferralPost.active_posts` in your controller
  # instead of `ReferralPost.where(status: :active).order(created_at: :desc)`
  scope :active_posts, -> { where(status: :active).order(created_at: :desc) }

  # Ensure questions is always an array (guards in case DB nulls sneak in)
  def questions
    (super || []).map(&:to_s)
  end
end
